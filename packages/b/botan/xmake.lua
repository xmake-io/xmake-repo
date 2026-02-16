package("botan")
    set_homepage("https://botan.randombit.net")
    set_description("Cryptography Toolkit")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/randombit/botan/archive/refs/tags/$(version).tar.gz",
             "https://github.com/randombit/botan.git")

    add_versions("3.9.0", "89dabf2e9bdb889242f73e579ac7e25e095e28e549bf83a00357602bc47f2618")
    add_versions("3.8.1", "8eb79a49c1a3f7e5e7563c13752a37557de935cdac48d9221ea4b580158e8965")
    add_versions("3.7.1", "8d2a072c7cdca6cadd16f89bb966fce1b3ec77cb4614bf1d87dec1337a3d2330")
    add_versions("3.7.0", "ebd1b965ed2afa12dfaf47650187142cbe870b99528185c88ca7c0ac19307c6c")
    add_versions("3.6.1", "a6c4e8dcb6c7f4b9b67e2c8b43069d65b548970ca17847e3b1e031d3ffdd874a")
    add_versions("3.6.0", "950199a891fab62dca78780b36e12f89031c37350b2a16a2c35f2e423c041bad")
    add_versions("3.5.0", "7d91d3349e6029e1a6929a50ab587f9fd4e29a9af3f3d698553451365564001f")
    add_versions("3.4.0", "6ef2a16a0527b1cfc9648a644877f7b95c4d07e8ef237273b030c623418c5e5b")

    -- Backport MSVC flags regression after 3.5.0 (fixed in 3.7.0: https://github.com/randombit/botan/pull/4452)
    add_patches(">=3.6.0 <3.7.0", "patches/3.6.0/msvc-compiler-flags.patch", "fc41a662f34a5fa52b232b25a396f595984698dc0029e4aa75423c8c4782028c")

    add_configs("tools", {description = "Build tools.", default = false, type = "boolean"})
    add_configs("python", {description = "Enable python module", default = false, type = "boolean"})
    add_configs("endian", {description = [[The  parameter should be either “little” or “big”. If not used then if the target architecture has a default, that is used. Otherwise left unspecified, which causes less optimal codepaths to be used but will work on either little or big endian.]], default = nil, type = "string", values = {"little", "big"}})
    add_configs("modules", {description = [[Enable modules, example: {configs = {modules = {"zlib", "lzma"}}}]], type = "table"})
    add_configs("minimal", {description = "Build a minimal version", default = true, type = "boolean"})
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

    if on_check then
        on_check("windows", function (package)
            import("core.tool.toolchain")

            local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
            if msvc then
                local vs = msvc:config("vs")
                assert(vs and tonumber(vs) >= 2022, "package(botan): current version need vs >= 2022")
            end
        end)
    end

    on_load(function (package)
        import("core.base.hashset")

        local major = "3"
        if package:version() then
            major = package:version():major()
        end
        package:add("includedirs", "include/botan-" .. major)

        local modules = package:config("modules")
        if modules then
            local deps = hashset.from(modules)
            if deps then
                for _, dep in ipairs({"boost", "bzip2", "lzma", "sqlite3", "zlib"}) do
                    if deps:has(dep) then
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
        end

        if not package:is_plat("windows") then
            -- Patch to support versions of ar that don't support response files (which are first used in 3.6.0)
            package:add("patches", ">=3.6.0", "patches/3.6.0/ar-response-files.patch", "864443a77921d9da970cebe5b413e8ee18c60205011364b7bb422a65193ecb5f")
        end
    end)

    on_install("windows", "linux", "macosx|native", "bsd", "mingw@windows", "msys", "wasm", function (package)
        -- https://botan.randombit.net/handbook/building.html
        local configs = {
            "configure.py",
            "--prefix=" .. package:installdir(),
            "--build-tool=ninja",
            "--without-documentation",
        }

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
                -- let configure.py detech bsd host name
                table.insert(configs, "--os=" .. package:plat())
            end
            local arch = package:arch()
            if arch == "arm64-v8a" then
                arch = "arm64"
            end
            table.insert(configs, "--cpu=" .. arch)
        end

        if package:is_debug() then
            table.insert(configs, "--debug-mode")
        end

        local targets = (package:config("shared") and "shared" or "static")
        if package:config("tools") then
            targets = targets .. ",cli"
        end
        table.insert(configs, "--build-targets=" .. targets)

        -- necessary functions were moved to a separate module in 3.7.0
        local modules = package:config("modules")
        local needs_os_utils = package:version():ge("3.7.0")
        if modules then
            if needs_os_utils and not table.contains(modules, "os_utils") then
                table.insert(modules, "os_utils")
            end
            table.insert(configs, "--enable-modules=" .. table.concat(modules, ","))
        elseif needs_os_utils then
            table.insert(configs, "--enable-modules=os_utils")
        end

        if not package:config("python") then
            table.insert(configs, "--no-install-python-module")
        end

        if package:config("endian") then
            table.insert(configs, "--with-endian=" .. package:config("endian"))
        end

        if package:config("minimal") then
            table.insert(configs, "--minimized-build")
        end

        local cxflags = {}
        table.join2(cxflags, table.wrap(package:config("cxflags")))
        table.join2(cxflags, table.wrap(package:config("cxxflags")))
        for _, flag in ipairs(cxflags) do
            table.insert(configs, "--extra-cxxflags=" .. flag)
        end

        for _, dep in ipairs({"boost", "bzip2", "xz", "sqlite3", "zlib"}) do
            local packagedep = package:dep(dep)
            if packagedep then
                local fetchinfo = packagedep:fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        table.insert(configs, "--with-external-includedir=" .. includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(configs, "--with-external-libdir=" .. linkdir)
                    end
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

        if not package:is_cross() and package:config("tools") then
            os.vrun("botan-cli version")
        end
    end)
