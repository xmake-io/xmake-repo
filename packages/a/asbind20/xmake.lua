package("asbind20")
    set_homepage("https://asbind20.readthedocs.io/")
    set_description("C++20 AngelScript binding library")
    set_license("MIT")

    add_urls("https://github.com/HenryAWE/asbind20/archive/refs/tags/$(version).tar.gz",
             "https://github.com/HenryAWE/asbind20.git")

    add_versions("1.8.0", "cbc4b68cfbd39c96225d2f1509d0f842678b98b0cafa682daef24dc773e5bbc9")
    add_versions("1.7.1", "076afaa81eb880440c8c83df1a54cff04c72d5b0633dbe93776882bdc02348e6")
    add_versions("1.7.0", "43d0cbb0edb64b35f4a847cf16dbb41bd94d13d2cb7cdc4187de2e1d03869652")
    add_versions("1.6.0", "e936b5c1c89d7e66165f34ba4f536faab9fea397c36172b3e455436d525da461")

    add_deps("cmake")
    add_deps("angelscript >= 2.37.0")

    -- Shared library is not supported by current release (1.6) --
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("ext", {description = "Build the extensions.", default = true, type = "boolean"})

    on_check(function (package)
        if package:is_plat("mingw") then
            if is_host("macosx") and package:is_arch("i386") then
                assert(false, "package(asbind20): Unsupported on mingw|i386")
            end
        end
        assert(package:check_cxxsnippets({test = [[
            #include <concepts>
            void test(std::signed_integral auto x) {
                static_assert(std::integral<int>);
                static_assert(std::floating_point<double>);
                static_assert(std::same_as<int, signed>);
                static_assert(std::convertible_to<int, long>);
            }
        ]]}, {configs = {languages = "c++20"}}), "package(asbind20): need std::convertible_to from <concepts> header.")
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
