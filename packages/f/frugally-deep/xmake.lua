package("frugally-deep")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Dobiasd/frugally-deep")
    set_description("Header-only library for using Keras (TensorFlow) models in C++.")
    set_license("MIT")

    add_urls("https://github.com/Dobiasd/frugally-deep/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Dobiasd/frugally-deep.git")

    add_versions("v0.16.2", "b16af09606dcf02359de53b7c47323baaeda9a174e1c87e126c3127c55571971")
    add_versions("v0.16.0", "5ffe8dddb43a645094b2ca1d48e4ee78e685fbef3c89f08cea8425a39dad9865")
    add_versions("v0.15.31", "49bf5e30ad2d33e464433afbc8b6fe8536fc959474004a1ce2ac03d7c54bc8ba")
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
        local cxflags
        if package:is_plat("mingw") then
            cxflags = "-Wa,-mbig-obj"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <fdeep/fdeep.hpp>
            void test() {
                const auto model = fdeep::load_model("fdeep_model.json");
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}}))
    end)
