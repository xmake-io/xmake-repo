package("ntkernel-error-category")
    set_homepage("https://github.com/ned14/ntkernel-error-category")
    set_description("A C++ 11 std::error_category for the NT kernel's NTSTATUS error codes ")
    set_license("Apache-2.0")

    add_urls("https://github.com/ned14/ntkernel-error-category/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ned14/ntkernel-error-category.git")
    add_versions("v1.0.0", "481b60ac0b1d2c179120b3e6589884217508b6b5025a25dd6bf47399aa5d2cc5")

    add_configs("headeronly", {description = "Use header only version.", default = true, type = "boolean"})

    on_install(function (package)
        local configs = {}
        if package:config("headeronly") then
            configs.kind = "headeronly"
            package:add("defines", "NTKERNEL_ERROR_CATEGORY_INLINE")
        elseif not package:config("configs.shared") then
            package:add("defines", "NTKERNEL_ERROR_CATEGORY_STATIC")
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
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
