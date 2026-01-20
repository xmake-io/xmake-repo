package("gmp")
    set_homepage("https://gmplib.org/")
    set_description("GMP is a free library for arbitrary precision arithmetic, operating on signed integers, rational numbers, and floating-point numbers.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gmp/gmp-$(version).tar.xz")
    add_urls("https://ftp.gnu.org/gnu/gmp/gmp-$(version).tar.xz")
    add_urls("https://gmplib.org/download/gmp/gmp-$(version).tar.xz")

    add_versions("6.3.0", "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898")

    add_patches("6.3.0", "patches/6.3.0/c23.patch", "24eb6ad75fb2552db247d3c5c522d30f221cca23a0fdc925b2684af44d51b7b3")

    add_configs("cpp_api", {description = "Enable C++ support", default = false, type = "boolean"})
    if is_plat("windows") and is_arch("arm64") then
        add_configs("assembly", {description = "Enable the use of assembly loops", default = false, type = "boolean"})
    else
        add_configs("assembly", {description = "Enable the use of assembly loops", default = true, type = "boolean"})
    end
    add_configs("fat", {description = "Build fat libraries on systems that support it", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::gmp")
    elseif is_plat("linux") then
        add_extsources("pacman::gmp", "apt::libgmp-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::gmp")
    end

    if not is_subhost("windows") then
        add_deps("m4")
    end

    add_links("gmpxx", "gmp")

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") then
                if package:has_tool("cxx", "clang_cl") then
                    raise("package(gmp) unsupported clang-cl toolchain now, you can use clang toolchain\nadd_requires(\"gmp\", {configs = {toolchains = \"clang\"}}))")
                end
            end
        end)
    end

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_package("system::gmp", {includes = "gmp.h"})
        end
    end)

    on_load(function (package)
        if is_subhost("windows") and os.arch() == "x64" then
            local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
            package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true}})
        end
        if package:is_plat("windows") then
            -- msvc toolchain require other tool to build asm
            -- x86, x64 -> yasm, arm64 -> clang
            if package:is_arch("x64", "x86") then
                package:add("deps", "yasm")
            end

            package:add("defines", "__GMP_WITHIN_CONFIGURE")
            if package:is_arch("x64", "arm64") then
                package:add("defines", "_LONG_LONG_LIMB") -- mp_limb_t type
            end
            -- if package:config("shared") then
            --     package:add("defines", "__GMP_LIBGMP_DLL")
            -- end
        end
    end)

    on_install("!wasm and (!android or android@!windows)", function (package)
        import("package.tools.autoconf")
        import("lib.detect.find_tool")

        -- ref https://github.com/microsoft/vcpkg/blob/4ed84798137bcf664989fa432d41d278d7ad3b25/ports/gmp/subdirs.patch
        io.replace("Makefile.am",
            "SUBDIRS = tests mpn mpz mpq mpf printf scanf rand cxx demos tune doc",
            "SUBDIRS = mpn mpz mpq mpf printf scanf rand cxx tune", {plain = true})
        if is_host("windows") then
            io.replace("configure", "LIBTOOL='$(SHELL) $(top_builddir)/libtool'", "LIBTOOL='\"$(SHELL)\" $(top_builddir)/libtool'", {plain = true})
        end
        if package:is_plat("windows") then
            -- Let asm code use windows abi
            io.replace("configure", "*-*-mingw* | *-*-msys | *-*-cygwin)", "*-*-msvc)", {plain = true})
            local obj_file_suffix = package:has_tool("cxx", "cl") and ".obj" or ".o"
            io.replace("configure", "$CCAS $CFLAGS $CPPFLAGS", "$CCAS $CCASFLAGS -o conftest" .. obj_file_suffix, {plain = true})
            -- Remove error flags for asm build
            io.replace("mpn/Makefile.in", "$(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) $(ASMFLAGS)", "$(AM_CFLAGS) ${CCASFLAGS}", {plain = true})
            if package:has_tool("ld", "link") then
                -- `lib /out: xxx` -> `lib /out:xxx`
                io.replace("configure", "$AR $AR_FLAGS ", "$AR $AR_FLAGS", {plain = true})
            end
            if package:config("shared") then
                -- error: duplicate symbol: __gmpn_add
                io.replace("gmp-h.in", "#define __GMP_EXTERN_INLINE  __inline", "#define __GMP_EXTERN_INLINE  static __inline", {plain = true})
                -- export symbol macro
                io.replace("gmp-h.in", "#define __GMP_LIBGMP_DLL  @LIBGMP_DLL@", "#define __GMP_LIBGMP_DLL  1", {plain = true})
            end
        end

        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-cxx=" .. (package:config("cpp_api") and "yes" or "no"))
        table.insert(configs, "--enable-assembly=" .. (package:config("assembly") and "yes" or "no"))
        table.insert(configs, "--enable-fat=" .. (package:config("fat") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        if not package:is_plat("windows") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end

        local opt = {}
        if package:is_plat("macosx") and package:is_arch("arm64") and os.arch() == "x86_64" then
            table.insert(configs, "--build=x86_64-apple-darwin")
            table.insert(configs, "--host=arm64-apple-darwin")
            opt.envs = autoconf.buildenvs(package, {cflags = "--target=arm64-apple-darwin"})
            opt.envs.CC = package:build_getenv("cc") .. " -arch arm64" -- for linker flags
        elseif package:is_plat("windows") then
            local msvc = package:toolchain("msvc") or package:toolchain("clang") or package:toolchain("clang-cl")
            assert(msvc:check(), "msvs not found!")
            -- buildenvs maybe missing deps bin dir
            opt.envs = os.joinenvs(os.joinenvs(msvc:runenvs()), autoconf.buildenvs(package))
            if package:has_tool("cxx", "cl") then
                opt.envs.CC  = "cl -nologo"
                opt.envs.CXX = "cl -nologo"
                opt.envs.AR  = "lib -nologo"
                opt.envs.LD  = "link -nologo"
                opt.envs.NM = "dumpbin -nologo -symbols"
                opt.envs.AR_FLAGS = "-out:" -- override `cq` flag
                table.insert(configs, "gmp_cv_asm_w32=.word") -- fix detect
            elseif package:has_tool("cxx", "clang") then
                local clang_fname = path.filename(opt.envs.CC)
                local suffix = clang_fname:split("-")
                if #suffix > 1 then
                    suffix = "-" .. suffix[#suffix]
                else
                    suffix = ""
                end
                opt.envs.NM = "llvm-nm" .. suffix
                opt.envs.LDFLAGS = opt.envs.LDFLAGS:gsub("-nostdlib", "")
                if package:is_cross() then
                    -- require -fuse-ld=lld-link
                    opt.envs.CFLAGS = opt.envs.CFLAGS .. " " .. opt.envs.LDFLAGS
                    opt.envs.CXXFLAGS = opt.envs.CXXFLAGS .. " " .. opt.envs.LDFLAGS
                end
            end
            -- Maybe missing ucrt flags
            opt.envs.CFLAGS = opt.envs.CFLAGS .. " " .. opt.envs.CXXFLAGS
            -- Fix mp_limb_t
            -- msvc sizeof long == 4 unmatch gcc sizeof long == 8
            if package:is_arch("x64", "arm64") then
                opt.envs.CFLAGS = opt.envs.CFLAGS .. " -D_LONG_LONG_LIMB"
                opt.envs.CXXFLAGS = opt.envs.CXXFLAGS .. " -D_LONG_LONG_LIMB"
            end

            local clang_archs = {
                ["x86"] = "i686",
                ["x64"] = "x86_64",
                ["arm64"] = "aarch64",
            }
            local target = clang_archs[package:arch()] .. "-windows-msvc"
            if package:is_arch("x64", "x86") then
                local yasm_machine = {
                    ["x86"] = "x86",
                    ["x64"] = "amd64",
                }
                local yasm_format = {
                    ["x86"] = "win32",
                    ["x64"] = "win64",
                }
                opt.envs.CCAS = "yasm"
                opt.envs.CCASFLAGS = format("-a x86 -m %s -p gas -r raw -f %s -g null -X gnu", yasm_machine[package:arch()], yasm_format[package:arch()])
            elseif package:is_arch("arm64") then
                if package:has_tool("cxx", "clang") then
                    opt.envs.CCAS = opt.envs.CC
                else
                    local llvm_nm = assert(find_tool("llvm-nm"), "windows arm64 require llvm-nm to detect")
                    local clang = assert(find_tool("clang"), "windows arm64 require clang to build asm")
                    opt.envs.CCAS = path.unix(clang.program)
                    opt.envs.NM = path.unix(llvm_nm.program)
                end
                opt.envs.CCASFLAGS = table.concat({"--target=" .. target, "-c"}, " ")
            end
            table.insert(configs, "--host=" .. target)
        end
        -- Can't generate correct gmp.lib with lib.exe
        if package:is_plat("windows") then
            autoconf.build(package, configs, opt)

            -- I don't know why, it only happen on ci
            os.trymv("dummy.obj", "cxx/")

            io.writefile("xmake.lua", [[
                option("cpp_api", {default = false})
                add_rules("mode.debug", "mode.release")
                target("gmp")
                    set_kind("$(kind)")
                    add_rules("c++")
                    add_files("**.obj|gen-*.obj|cxx/*.obj", "**.o|gen-*.o|cxx/*.o")
                    add_headerfiles("gmp.h")
                target("gmpxx")
                    set_default(has_config("cpp_api"))
                    set_kind("$(kind)")
                    add_rules("c++")
                    add_files("cxx/*.obj", "cxx/*.o")
                    add_headerfiles("gmpxx.h")
                    add_deps("gmp")
            ]])
            import("package.tools.xmake").install(package, {cpp_api = package:config("cpp_api")})
        else
            autoconf.install(package, configs, opt)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gmp_version", {includes = "gmp.h"}))
    end)
