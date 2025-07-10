package("asbind20")
    set_homepage("https://asbind20.readthedocs.io/")
    set_description("C++20 AngelScript binding library")
    set_license("MIT")

    add_urls("https://github.com/HenryAWE/asbind20/archive/refs/tags/$(version).tar.gz",
             "https://github.com/HenryAWE/asbind20.git")

    add_versions("1.6.0", "e936b5c1c89d7e66165f34ba4f536faab9fea397c36172b3e455436d525da461")

    add_deps("cmake")
    add_deps("angelscript >= 2.37.0")

    -- Shared library is not supported by current release (1.6) --
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("ext", {description = "Build the extensions.", default = true, type = "boolean"})

    on_check("mingw", function (package)
        if is_host("macosx") and package:is_arch("i386") then
            assert(false, "package(asbind): Unsupported on mingw|i386")
        end
    end)

    on_check("android", function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <concepts>
            template <typename T>
            concept raw_data_view = requires {
                              T.data()->std::is_pointer_v;
                              T.size()->std::convertible_to(std::size_t);
            };
            void test() {
                std::cout << "test";
            }
        ]]}, {configs = {languages = "c++20"}}), "package(asbind20): need std::convertible_to from <concepts> header.")
        if package:version() and package:version():ge("3.0.0") then
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(ada >=3.0.0) require ndk version > 22")
        end
    end)

    on_load(function (package)
        -- The core library is header-only --
        if not package:config("ext") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("windows", "linux", "android", "msys", "mingw", function (package)
        if package:is_plat("windows") and package:is_arch("arm64") then
            -- Exported target namespace starts with capital letter, but XMake auto-generated CMakeConfig defines it as angelscript::angelscript
            io.replace("CMakeLists.txt", "Angelscript::angelscript", "angelscript::angelscript", {plain = true})
        end
        local configs = {}
        table.insert(configs, "-Dasbind_build_ext=" .. (package:config("ext") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("ext") then
            assert(package:check_cxxsnippets({test = [[
                #include <asbind20/ext/stdstring.hpp>
                void test() {
                    auto engine = asbind20::make_script_engine();
                    asbind20::ext::configure_engine_for_ext_string(engine);
                }
            ]]}, {configs = {languages = "c++20"}}))
        end
        assert(package:check_cxxsnippets({test = [[
            #include <asbind20/asbind.hpp>
            void test() {
                auto engine = asbind20::make_script_engine();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
