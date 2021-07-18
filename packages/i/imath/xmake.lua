package("imath")

    set_homepage("https://github.com/AcademySoftwareFoundation/Imath/")
    set_description("Imath is a C++ and python library of 2D and 3D vector, matrix, and math operations for computer graphics")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/Imath.git")
    add_versions("v3.1.0", "211c907ab26d10bd01e446da42f073ee7381e1913d8fa48084444bc4e1b4ef87")

    on_load(function (package)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Imath::V3f a(0, 0, 0);
                Imath::V3f b(1, 1, 1);
                Imath::V3f c(2, 9, 2);
                Imath::Box3f box(a);
                box.extendBy(c);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "Imath/ImathBox.h"}))
    end)
