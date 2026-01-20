package("seqan3")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.seqan.de")
    set_description("The modern C++ library for sequence analysis. Contains version 3 of the library and API docs.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/seqan/seqan3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/seqan/seqan3.git")

    add_versions("3.4.0", "8e000e6788f1e2ada071b36f64231d56f18e2d687ab4122d86cd3aefc6c87743")
    add_versions("3.3.0", "96975406445c8a5974803eefa146ee2f85206f6d2c2bccf45171ee0b1a653fb8")
    add_versions("3.2.0", "80d41dd035407cfec83eb3a4466d0421adc27129af684290c0c4da31421e7276")

    add_configs("cereal", {description = "required for serialisation and CTD support", default = false, type = "boolean"})
    add_configs("zlib", {description = "required for *.gz and .bam file support", default = false, type = "boolean"})
    add_configs("bzip2", {description = "required for *.bz2 file support", default = false, type = "boolean"})

    if is_plat("windows") then
        add_cxxflags("/Zc:__cplusplus")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("sdsl-lite")

    on_load(function (package)
        if package:config("cereal") then
            package:add("deps", "cereal >=1.3.1")
        end
        if package:config("zlib") then
            package:add("deps", "zlib >=1.2")
            package:add("defines", "SEQAN3_HAS_ZLIB=1")
        end
        if package:config("bzip2") then
            package:add("deps", "bzip2 >=1.0")
            package:add("defines", "SEQAN3_HAS_BZIP2=1")
        end
    end)

    if on_check then
        on_check(function (package)
            import("core.base.semver")
            import("lib.detect.find_tool")
            
            if package:is_plat("android") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) >= 27, "package(seqan3) require ndk version >= 27")
            end

            local check_map = {
                ["3.2.0"] = { gcc = ">=10.0", clang = "unsupported" },
                ["3.3.0"] = { gcc = ">=11.0", clang = "unsupported" },
                ["3.4.0"] = { gcc = ">=12.0", clang = ">=17.0" },
            }

            local info
            if package:has_tool("cc", "gcc", "gxx") then
                info = find_tool("gcc", {version = true})
            elseif package:has_tool("cc", "clang", "clangxx") then
                info = find_tool("clang", {version = true})
            end
            local check = check_map[package:version():rawstr()]
            if info == nil or check == nil or check[info.name] == nil then
                return
            end

            assert(semver.satisfies(info.version, check[info.name]), "package(seqan3): unsupported compiler")
        end)
    end

    on_install("linux", "macosx", "bsd", "android", "iphoneos", "cross", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <seqan3/core/debug_stream.hpp>
            void test() {
                seqan3::debug_stream << "Hello World!\n";
            }
        ]]}, {configs = {languages = package:version():ge("3.4.0") and "c++23" or "c++20"}}))
    end)
