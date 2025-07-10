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
            #include <type_traits>
            #include <cstddef>
            #include <concepts>
            using namespace std;
            #define MINICRC_REQUIRES(Concept, T) typename T, Concept<T> = false
            namespace minicrc {
            template <typename T>
            using byte_sized =
                typename std::enable_if<sizeof(T) == sizeof(byte), bool>::type;
            template <typename T>
            using raw_data_view = typename std::enable_if<
                std::is_pointer<
                    decltype(static_cast<remove_cvref_t<T>*>(nullptr)->data())>::value &&
                    std::is_convertible<
                        decltype(static_cast<remove_cvref_t<T>*>(nullptr)->size()),
                        std::size_t>::value,
                bool>::type;
            template <typename T>
            using unsigned_integral = typename std::enable_if<
                !std::is_signed<T>::value && std::is_integral<T>::value, bool>::type;
            }
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
