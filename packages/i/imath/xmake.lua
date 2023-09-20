package("imath")

    set_homepage("https://github.com/AcademySoftwareFoundation/Imath/")
    set_description("Imath is a C++ and python library of 2D and 3D vector, matrix, and math operations for computer graphics")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/Imath.git")
    add_versions("v3.1.0", "211c907ab26d10bd01e446da42f073ee7381e1913d8fa48084444bc4e1b4ef87")
    add_versions("v3.1.1", "a63fe91d8d0917acdc31b0c9344b1d7dbc74bf42de3e3ef5ec982386324b9ea4")
    add_versions("v3.1.2", "f21350efdcc763e23bffd4ded9bbf822e630c15ece6b0697e2fcb42737c08c2d")
    add_versions("v3.1.3", "0bf7ec51162c4d17a4c5b850fb3f6f7a195cff9fa71f4da7735f74d7b5124320")
    add_versions("v3.1.4", "fcca5fbb37d375a252bacd8a29935569bdc28b888f01ef1d9299ca0c9e87c17a")
    add_versions("v3.1.5", "1e9c7c94797cf7b7e61908aed1f80a331088cc7d8873318f70376e4aed5f25fb")
    add_versions("v3.1.9", "f1d8aacd46afed958babfced3190d2d3c8209b66da451f556abd6da94c165cf3")

    on_load(function (package)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw@windows", "mingw@msys", function (package)
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
