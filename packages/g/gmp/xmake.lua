package("gmp")
    set_homepage("https://gmplib.org/")
    set_description("GMP is a free library for arbitrary precision arithmetic, operating on signed integers, rational numbers, and floating-point numbers.")
    set_license("LGPL-3.0")

    add_urls("https://ftp.gnu.org/gnu/gmp/gmp-$(version).tar.xz")
    add_urls("https://gmplib.org/download/gmp/gmp-$(version).tar.xz")

    add_versions("6.3.0", "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898")

    add_patches("6.3.0", "patches/6.3.0/c23.patch", "24eb6ad75fb2552db247d3c5c522d30f221cca23a0fdc925b2684af44d51b7b3")
    if is_plat("windows") then
        add_patches("6.3.0", "patches/6.3.0/windows.patch", "4a50c5174607535fe65e020b0b5e9eb1d1ee1e3b11953c90de932dcff6bdc964")
    end

    add_configs("cpp_api", {description = "Enable C++ support", default = false, type = "boolean"})
    add_configs("assembly", {description = "Enable the use of assembly loops", default = true, type = "boolean"})
    add_configs("fat", {description = "Build fat libraries on systems that support it", default = false, type = "boolean"})

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


    if on_check then
        on_check(function (package)
            if package:is_plat("windows") then
                if package:has_tool("cxx", "clang_cl") then
                    raise("package(gmp) unsupported clang-cl toolchain now, you can use clang toolchain\nadd_requires(\"gmp\", {configs = {toolchains = \"clang\"}}))")
                end
            end
            if package:config("fat") then
                if package:is_plat("windows") then
                    raise("package(gmp) config(fat) is not supported on Windows MSVC")
                end
                if not package:is_arch("x86", "x86_64", "i386") then
                    raise("package(gmp) config(fat) is only supported on x86 and x86_64 architectures")
                end
                if package:config("assembly") == false then
                    raise("package(gmp) config(fat) requires assembly to be enabled")
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
        if package:config("cpp_api") then
            package:add("links", "gmpxx", "gmp")
            if not package:is_plat("windows") then
                package:add("syslinks", "m")
            end
        else
            package:add("links", "gmp")
        end

        if package:config("fat") then
            package:config_set("assembly", true)
        end

        if is_subhost("windows") and os.arch() == "x64" then
            local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
            package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true}})
        end
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "__GMP_LIBGMP_DLL")
            end

            if package:is_arch("x64", "arm64") then
                package:add("defines", "_LONG_LONG_LIMB") -- mp_limb_t type
            end

            if package:config("assembly") and package:is_arch("x86", "i386") and not package:has_tool("cxx", "clang") then
                package:add("deps", "yasm")
            end
        end
    end)

    on_install("!wasm and (!android or android@!windows)", function (package)
        import("package.tools.autoconf")
        import("lib.detect.find_tool")

        os.tryrm(".gdbinit")
        if not is_host("windows") and os.isfile("configure") then
            os.vrunv("chmod", {"+x", "configure"})
        end
        if is_host("windows") then
            io.replace("configure", "LIBTOOL='$(SHELL) $(top_builddir)/libtool'", "LIBTOOL='\"$(SHELL)\" $(top_builddir)/libtool'", {plain = true})
        end
        if package:is_plat("macosx") and package:is_cross() then
            io.replace("configure", 'archive_cmds="\\$CC ', 'archive_cmds="\\$CC \\$LDFLAGS ', {plain = true})
        end
        if package:is_plat("windows") then
            if package:config("shared") then
                -- export symbol macro
                io.replace("gmp-h.in", "#define __GMP_LIBGMP_DLL  @LIBGMP_DLL@", "#define __GMP_LIBGMP_DLL  1", {plain = true})
            end
        end

        local enable_assembly = package:config("assembly")
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-cxx=" .. (package:config("cpp_api") and "yes" or "no"))
        table.insert(configs, "--enable-fat=" .. (package:config("fat") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        if not package:is_plat("windows") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end

        local opt = {}
        if package:is_plat("macosx") and package:is_cross() then
            local triples = {
                x86_64 = "x86_64-apple-darwin",
                arm64  = "arm64-apple-darwin",
                arm64e = "arm64-apple-darwin",
                i386   = "i386-apple-darwin",
            }
            local host_arch = os.arch()
            local target_arch = package:arch()
            local host_triple = triples[host_arch] or (host_arch .. "-apple-darwin")
            local target_triple = triples[target_arch] or (target_arch .. "-apple-darwin")
            table.insert(configs, "--build=" .. host_triple)
            table.insert(configs, "--host=" .. target_triple)
            opt.envs = autoconf.buildenvs(package, {cflags = "--target=" .. target_triple})
            opt.envs.CC = package:build_getenv("cc") .. " -arch " .. target_arch -- for linker flags
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
                opt.envs.NM  = "dumpbin -nologo -symbols"
                opt.envs.AR_FLAGS = "-out:" -- override `cq` flag
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
            -- Fix mp_limb_t
            -- msvc sizeof long == 4 unmatch gcc sizeof long == 8
            if package:is_arch("x64", "arm64") then
                opt.envs.CFLAGS = opt.envs.CFLAGS .. " -D_LONG_LONG_LIMB"
                opt.envs.CXXFLAGS = opt.envs.CXXFLAGS .. " -D_LONG_LONG_LIMB"
            end

            local clang_archs = {
                ["x86"] = "i686",
                ["i386"] = "i686",
                ["x64"] = "x86_64",
                ["arm64"] = "aarch64",
            }
            local target = (clang_archs[package:arch()] or package:arch()) .. "-windows-msvc"
            if enable_assembly then
                local clang = package:has_tool("cxx", "clang") and opt.envs.CC or find_tool("clang")
                if clang then
                    local clang_prog = type(clang) == "table" and clang.program or clang
                    local ccas_dir = path.directory(clang_prog)
                    if ccas_dir and ccas_dir ~= "" then
                        opt.envs.PATH = path.joinenv({path.unix(ccas_dir), opt.envs.PATH})
                    end
                    opt.envs.CCAS = path.filename(clang_prog)
                    opt.envs.ASMFLAGS = "--target=" .. target .. " -c"
                    if package:is_arch("arm64") and not package:has_tool("cxx", "clang") then
                        local llvm_nm = find_tool("llvm-nm")
                        if llvm_nm then
                            opt.envs.NM = path.unix(llvm_nm.program)
                        end
                    end
                elseif package:is_arch("x86", "i386") then
                    if package:dep("yasm") then
                        local yasm_bin = path.unix(package:dep("yasm"):installdir("bin"))
                        opt.envs.PATH = path.joinenv({yasm_bin, opt.envs.PATH})
                    end
                    opt.envs.CCAS = "yasm"
                    opt.envs.ASMFLAGS = "-a x86 -m x86 -p gas -r raw -f win32 -g null -X gnu"
                else
                    wprint("package(gmp): assembly disabled on windows %s (clang is required; yasm does not support arm64 and crashes on x64). Please install clang to enable assembly.", package:arch())
                    enable_assembly = false
                end
            end
            table.insert(configs, "--host=" .. target)
        end
        table.insert(configs, "--enable-assembly=" .. (enable_assembly and "yes" or "no"))
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
        if package:config("cpp_api") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    mpz_class a(12345);
                }
            ]]}, {includes = "gmpxx.h"}))
        end
    end)
