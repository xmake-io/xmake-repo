package("clhep")

    set_homepage("https://proj-clhep.web.cern.ch/proj-clhep/")
    set_description("CLHEP - A Class Library for High Energy Physics")
    set_license("LGPL-3.0")

    add_urls("https://proj-clhep.web.cern.ch/proj-clhep/dist1/clhep-$(version).tgz", {version = function (version) return version:gsub("%+", ".") end})
    add_versions("2.4.5+1", "2517c9b344ad9f55974786ae6e7a0ef8b22f4abcbf506df91194ea2299ce3813")
    add_versions("2.4.6+3", "fcd007f11b10ba4af28d027222b63148d0eb44ff7a082eee353bdf921f9c684a")

    add_patches("2.4.x", path.join(os.scriptdir(), "patches", "2.4.5.1", "kind.patch"), "60a65bbe05380f6cd89752bdd662bd1685a8944081c97746f7a0bd2d046edf9d")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    on_install("windows", "macosx", "linux", function (package)
        os.cd("CLHEP")
        if package:is_plat("windows") then
            io.replace("cmake/Modules/ClhepVariables.cmake", "/MD", "/" .. package:config("vs_runtime"), {plain = true})
            io.replace("Random/CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        end
        local configs = {"-DCLHEP_BUILD_DOCS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
    end)
 
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                HepGeom::Point3D<float> point(1, 2, 3);
                point.set(4, 5, 6);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "CLHEP/Geometry/Point3D.h"}))
    end)
