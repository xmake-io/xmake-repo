package("botan")
    set_homepage("https://botan.randombit.net")
    set_description("Cryptography Toolkit")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/randombit/botan/archive/refs/tags/$(version).tar.gz",
             "https://github.com/randombit/botan.git")

    add_versions("3.4.0", "6ef2a16a0527b1cfc9648a644877f7b95c4d07e8ef237273b030c623418c5e5b")

    add_configs("python", {description = "Enable python module", default = false, type = "boolean"})
    add_configs("endian", {description = [[The parameter should be either “little” or “big”. If not used then if the target architecture has a default, that is used. Otherwise left unspecified, which causes less optimal codepaths to be used but will work on either little or big endian.]], default = nil, type = "string", values = {"little", "big"}})

    add_deps("python 3.x", "ninja", {kind = "binary"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libbotan")
    elseif is_plat("linux") then
        add_extsources("pacman::botan", "apt::libbotan-2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::botan")
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        local major = "3"
        if package:version() then
            major = package:version():major()
        end
        package:add("includedirs", "include/botan-" .. major)
    end)

    on_install(function (package)
        -- https://botan.randombit.net/handbook/building.html
        local configs = {
            "configure.py",
            "--prefix=" .. package:installdir(),
            "--build-tool=ninja",
            "--without-documentation"
        }

        local cc
        if package:has_tool("cxx", "cl") then
            cc = "msvc"
        elseif package:has_tool("cxx", "clang_cl", "clang++") then
            cc = "clang"
        elseif package:has_tool("cxx", "g++") then
            cc = "gcc"
        end

        local cc_bin
        if package:is_plat("mingw") then
            cc = "gcc"
            cc_bin = package:build_getenv("cxx")
        elseif package:is_plat("wasm") then
            cc = "emcc"
            cc_bin = package:build_getenv("cxx")
        end

        local envs
        if package:is_plat("windows") then
            table.insert(configs, "--msvc-runtime=" .. package:runtimes())
            local msvc = package:toolchain("msvc")
            assert(msvc:check(), "vs not found!")
            envs = msvc:runenvs()
        end

        table.insert(configs, "--cc=" .. cc)
        if cc_bin then
            table.insert(configs, "--cc-bin=" .. cc_bin)
        end

        if package:is_plat("wasm") then
            table.insert(configs, "--os=emscripten")
            table.insert(configs, "--cpu=wasm")
        else
            table.insert(configs, "--os=" .. package:plat())
            table.insert(configs, "--cpu=" .. package:arch())
        end
        table.insert(configs, "--build-targets=" .. (package:config("shared") and "shared" or "static"))

        local cxxflags = table.join(table.wrap(package:build_getenv("cxflags")), package:build_getenv("cxxflags"))
        if #cxxflags ~= 0 then
            table.insert(configs, "--cxflags=" .. table.concat(cxxflags, " "))
        end

        local ldflags = table.join(table.wrap(package:build_getenv("ldflags")))
        if #ldflags ~= 0 then
            table.insert(configs, "--ldflags=" .. table.concat(ldflags, " "))
        end

        if not package:config("python") then
            table.insert(configs, "--no-install-python-module")
        end

        if package:config("endian") then
            table.insert(configs, "--with-endian=" .. package:config("endian"))
        end

        os.vrunv("python3", configs, {envs = envs})
        import("package.tools.ninja").install(package, {}, {envs = envs})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <botan/hash.h>
            #include <botan/hex.h>

            void test() {
                const auto hash1 = Botan::HashFunction::create_or_throw("SHA-256");
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
