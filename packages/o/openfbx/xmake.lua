package("openfbx")
    set_homepage("https://github.com/nem0/OpenFBX")
    set_description("Lightweight open source FBX importer")
    set_license("MIT")

    add_urls("https://github.com/nem0/OpenFBX/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nem0/OpenFBX.git")

    add_versions("v0.9", "d6495e05d469bf2c51b860bb0518db6fb2ccf1df9a542a6b1c0f618202641e94")

    add_deps("cmake")
    add_deps("libdeflate")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto s = ofbx::getError();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "ofbx.h"}))
    end)
