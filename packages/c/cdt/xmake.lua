package("cdt")
    set_homepage("https://artem-ogre.github.io/CDT/")
    set_description("Constrained Delaunay Triangulation (C++)")
    set_license("MPL-2.0")

    add_urls("https://github.com/artem-ogre/CDT/archive/refs/tags/$(version).tar.gz",
             "https://github.com/artem-ogre/CDT.git")

    add_versions("1.4.1", "86df99eb5f02a73eeb8c6ea45765eed0d7f206e8d4d9f6479f77e3c590ae5bb3")

    add_deps("cmake")

    on_install(function (package)
        os.cd("CDT")
        local configs = {"-DCDT_USE_AS_COMPILED_LIBRARY=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <CDT.h>
            using namespace CDT;
            void test() {
                auto cdt = Triangulation<double>{};
                cdt.insertVertices({
                    {0.0, 1e38},
                    {1.0, 1e38},
                });
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
