package("botan")
    set_homepage("https://botan.randombit.net")
    set_description("Cryptography Toolkit")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/randombit/botan/archive/refs/tags/$(version).tar.gz",
             "https://github.com/randombit/botan.git")

    add_versions("3.4.0", "6ef2a16a0527b1cfc9648a644877f7b95c4d07e8ef237273b030c623418c5e5b")

    add_configs("python", {description = "Enable python module", default = false, type = "boolean"})
    add_configs("endian", {description = [[The parameter should be either “little” or “big”. If not used then if the target architecture has a default, that is used. Otherwise left unspecified, which causes less optimal codepaths to be used but will work on either little or big endian.]], default = nil, type = "string", values = {"little", "big"}})
    add_configs("enable_modules", {description = "Enable modules", default = nil, type = "string"})
    if is_plat("wasm") then 
          add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true}) 
    end

    add_deps("python 3.x", "ninja", {kind = "binary"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libbotan")
    elseif is_plat("linux") then
        add_extsources("pacman::botan", "apt::libbotan-2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::botan")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        local major = "3"
        if package:version() then
            major = package:version():major()
        end
        package:add("includedirs", "include/botan-" .. major)

        local modules = package:config("enable_modules")
        if modules then
            for _, dep in ipairs({"bzip2", "lzma", "sqlite3", "zlib"}) do
                if modules:find(dep) then
                    if dep == "boost" then
                        package:add("deps", "boost", {configs = {filesystem = true}})
                    elseif dep == "lzma" then
                        package:add("deps", "xz")
                    else
                        package:add("deps", dep)
                    end
                end
            end
        end
    end)

    on_install("windows", "linux", "macosx|native", "bsd", "mingw@windows", "msys", "wasm", function (package)
        -- https://botan.randombit.net/handbook/building.html
        local configs = {
            "configure.py",
            "--prefix=" .. package:installdir(),
            "--build-tool=ninja",
            "--without-documentation",
            "--minimized-build",
        }

        -- env setup
        local cc
        local envs
        if package:is_plat("windows") then
            local msvc = package:toolchain("msvc")
            assert(msvc:check(), "vs not found!")

            local vs = msvc:config("vs")
            if tonumber(vs) < 2019 then
                raise("This version of Botan requires at least msvc 19.30")
            end

            envs = msvc:runenvs()
            table.insert(configs, "--msvc-runtime=" .. package:runtimes())

            if package:has_tool("cxx", "cl") then
                cc = "msvc"
            elseif package:has_tool("cxx", "clang_cl") then
                raise("Unsupported toolchains on windows")
            end
        else
            local cxx = package:build_getenv("cxx")

            if cxx:find("clang", 1, true) then
                cc = "clang"
            elseif cxx:find("gcc", 1, true) then
                cc = "gcc"
            end

            local cc_bin
            if package:is_plat("mingw") then
                cc = "gcc"
                cc_bin = cxx
            elseif package:is_plat("wasm") then
                cc = "emcc"
                cc_bin = cxx
            end
        end

        if cc then
            table.insert(configs, "--cc=" .. cc)
        end
        if cc_bin then
            table.insert(configs, "--cc-bin=" .. cc_bin)
        end

        if package:is_plat("wasm") then
            table.insert(configs, "--os=emscripten")
            table.insert(configs, "--cpu=wasm")
        else
            if package:is_plat("iphoneos") then
                table.insert(configs, "--os=ios")
            elseif not package:is_plat("bsd") then
                table.insert(configs, "--os=" .. package:plat())
            end
            table.insert(configs, "--cpu=" .. package:arch())
        end

        -- configs setup
        if package:is_debug() then
            table.insert(configs, "--debug-mode")
        end
        table.insert(configs, "--build-targets=" .. (package:config("shared") and "shared" or "static"))

        if package:config("enable_modules") then
            table.insert(configs, "--enable-modules=" .. package:config("enable_modules"))
        end

        if not package:config("python") then
            table.insert(configs, "--no-install-python-module")
        end

        if package:config("endian") then
            table.insert(configs, "--with-endian=" .. package:config("endian"))
        end

        -- deps setup
        for _, dep in ipairs(package:orderdeps()) do
            if dep:name() == "xz" then
                table.insert(configs, "--with-lzma")
            else
                table.insert(configs, "--with-" .. dep:name())
            end

            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(configs, "--with-external-includedir=" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(configs, "--with-external-libdir=" .. linkdir)
                end
            end
        end

        os.vrunv("python3", configs, {envs = envs})
        import("package.tools.ninja").install(package, {}, {envs = envs})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <botan/hex.h>
            void test() {
                std::vector<uint8_t> key = Botan::hex_decode("000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F");
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
