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

    on_load(function (package)
        -- The core library is header-only --
        if not package:config("ext") then
            package:set("library", {headeronly = true})
        end
    end)

    on_install(function (package)
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
        else
            assert(package:check_cxxsnippets({test = [[
                #include <asbind20/asbind.hpp>
                void test() {
                    auto engine = asbind20::make_script_engine();
                }
            ]]}, {configs = {languages = "c++20"}}))
        end
    end)
