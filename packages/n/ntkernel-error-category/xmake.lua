package("ntkernel-error-category")
    set_homepage("https://github.com/ned14/ntkernel-error-category")
    set_description("A C++ 11 std::error_category for the NT kernel's NTSTATUS error codes ")
    set_license("Apache-2.0")

    add_urls("https://github.com/ned14/ntkernel-error-category/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ned14/ntkernel-error-category.git")
    add_versions("v1.0.0", "481b60ac0b1d2c179120b3e6589884217508b6b5025a25dd6bf47399aa5d2cc5")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})
    add_configs("headeronly", {description = "Use header only version.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
            package:config_set("headeronly", false)
        end

        if package:config("headeronly") then
            package:set("kind", "library", {headeronly = true})
            package:add("defines", "NTKERNEL_ERROR_CATEGORY_INLINE")
        elseif not package:config("shared") then
            package:add("defines", "NTKERNEL_ERROR_CATEGORY_STATIC")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            io.replace("CMakeLists.txt", "if(NOT PROJECT_IS_DEPENDENCY)", "if(0)", {plain = true})

            local configs = {"-DBUILD_TESTING=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)

            if package:config("shared") then
                os.tryrm(package:installdir("lib/*ntkernel-error-category_sl*"))
            else
                os.tryrm(package:installdir("bin/*.dll"))
                os.tryrm(package:installdir("lib/*ntkernel-error-category_dl*"))
            end
        else
            local configs = {}
            if package:config("headeronly") then
                configs.kind = "headeronly"
            end
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <system_error>
            #include <ntkernel-error-category/ntkernel_category.hpp>

            void test () {
                using namespace ntkernel_error_category;
                std::error_code ec(static_cast<int>(0xc000003a), ntkernel_category());
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
