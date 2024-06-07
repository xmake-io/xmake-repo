package("backportcpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bitwizeshift/BackportCpp")
    set_description("Library of backported modern C++ types to work with C++11")
    set_license("MIT")

    add_urls("https://github.com/bitwizeshift/BackportCpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bitwizeshift/BackportCpp.git")

    add_versions("v1.2.0", "8efded40a1d0e6674824336499d8706043a62bd8ae8aef62210c8c215f710b84")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bpstd/string_view.hpp>
            void test() {
                bpstd::string_view view;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
