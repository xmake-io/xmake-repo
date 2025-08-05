package("cdt")
    set_homepage("https://artem-ogre.github.io/CDT/")
    set_description("Constrained Delaunay Triangulation (C++)")
    set_license("MPL-2.0")

    add_urls("https://github.com/artem-ogre/CDT/archive/refs/tags/$(version).tar.gz",
             "https://github.com/artem-ogre/CDT.git", {submodules = false})

    add_versions("1.4.4", "97e57bdd1cf8219dcc81634236a502390a20dda3599dd3414a74343b7f03427f")
    add_versions("1.4.1", "86df99eb5f02a73eeb8c6ea45765eed0d7f206e8d4d9f6479f77e3c590ae5bb3")

    add_configs("exceptions", {description = "Enable the use of C++ exceptions", default = true, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "CDT_STATIC_DEFINE")
        end

        os.cd("CDT")
        local configs = {"-DCDT_USE_AS_COMPILED_LIBRARY=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCDT_DISABLE_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))
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
