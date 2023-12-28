package("frugally-deep")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Dobiasd/frugally-deep")
    set_description("Header-only library for using Keras (TensorFlow) models in C++.")
    set_license("MIT")

    add_urls("https://github.com/Dobiasd/frugally-deep/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Dobiasd/frugally-deep.git")

    add_versions("v0.15.29", "032cd525d4a7b9b3ebe28fd5e3984ac3e569da496f65d52c81030aabd9d0c52e")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("functionalplus", "eigen")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_install("windows", "macosx", "linux", "mingw", "cross", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fdeep/fdeep.hpp>
            void test() {
                const auto model = fdeep::load_model("fdeep_model.json");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
