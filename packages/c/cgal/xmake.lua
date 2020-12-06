package("cgal")

    set_homepage("https://www.cgal.org/")
    set_description("CGAL is a software project that provides easy access to efficient and reliable geometric algorithms in the form of a C++ library.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/CGAL/cgal/releases/download/v$(version)/CGAL-$(version)-library.zip")
    add_versions("5.1.1", "ceca7ea896505941878f6c1fb7a7ae86653fdd9b3d87b276da72227f173a9cd2")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("boost")
    if is_plat("macosx", "linux") then
        add_deps("gmp", "mpfr")
    end

    on_load("windows", function (package)
        if not package:config("header_only") then
            raise("Non-header-only version is not supported yet!")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        if package:config("header_only") then
            os.mv("include", package:installdir())
            os.mv("lib", package:installdir())
            return
        end
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF"}
        table.insert(configs, "-DCGAL_HEADER_ONLY=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        package:check_cxxsnippets({test = [[
            #include <vector>
            void test() {
                using K = CGAL::Epick_d<CGAL::Dynamic_dimension_tag>;
                using DT = CGAL::Delaunay_triangulation<K>;
                DT::Point p;
                std::vector<DT::Point> points;
            }
        ]]}, {config = {languages = "c++14"}, includes = {"CGAL/Epick_d.h", "CGAL/Delaunay_triangulation.h"}})
    end)
