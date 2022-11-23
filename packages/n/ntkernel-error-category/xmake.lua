package("ntkernel-error-category")
    set_homepage("https://github.com/ned14/ntkernel-error-category")
    set_description("A C++ 11 std::error_category for the NT kernel's NTSTATUS error codes ")
    set_license("Apache-2.0")

    add_urls("https://github.com/ned14/ntkernel-error-category/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ned14/ntkernel-error-category.git")
    add_versions("v1.0.0", "481b60ac0b1d2c179120b3e6589884217508b6b5025a25dd6bf47399aa5d2cc5")

    add_configs("header_only", {description = "Use header only version. (not supported atm)", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    on_install(function (package)
        local configs = {"-DPROJECT_IS_DEPENDENCY=ON", "-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local target = "ntkernel-error-category_"
        if package:config("header_only") then
            target = target .. "hl" 
        else 
            target = target .. (package:config("shared") and "_dl" or "_sl")
        end
        import("package.tools.cmake").install(package, configs, { target = target })
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
