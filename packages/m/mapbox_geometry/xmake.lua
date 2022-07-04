package("mapbox_geometry")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mapbox/geometry.hpp")
    set_description("Provides header-only, generic C++ interfaces for geometry types, geometry collections, and features.")
    set_license("ISC")

    add_urls("https://github.com/mapbox/geometry.hpp/archive/refs/tags/v$(version).zip",
             "https://github.com/mapbox/geometry.hpp.git")
    add_versions("1.1.0", "dc9203db94eda6b5377b96edeb4b53109cbf3d29e714d1d50c5cb598f2b39ab4")
    add_versions("2.0.3", "64d1005d4ee9931ac162b853cfb4a7c8a8bda9992ba83211386a6b40955bcc49")
    add_patches("1.1.0", path.join(os.scriptdir(), "patches", "1.1.0", "pragma.patch"), "38667632b6e4a0560edc3be27f3a8cbdf5392c47fec23ba85fc950886e23a01b")
    add_patches("2.0.3", path.join(os.scriptdir(), "patches", "2.0.3", "pragma.patch"), "38667632b6e4a0560edc3be27f3a8cbdf5392c47fec23ba85fc950886e23a01b")

    add_deps("mapbox_variant")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("mapbox_variant")
            add_rules("mode.debug", "mode.release")
            target("mapbox_geometry")
                set_kind("headeronly")
                add_headerfiles("include/(**/*.hpp)")
                add_rules("utils.install.cmake_importfiles")
                add_rules("utils.install.pkgconfig_importfiles")
        ]])

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, config)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mapbox/geometry/point.hpp>
            using mapbox::geometry::point;
            void test () {
                point<double> pt(1.0,0.0);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "mapbox/geometry/point.hpp"}))
    end)
