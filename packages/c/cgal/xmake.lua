package("cgal")

    set_homepage("https://www.cgal.org/")
    set_description("CGAL is a software project that provides easy access to efficient and reliable geometric algorithms in the form of a C++ library.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/CGAL/cgal/releases/download/v$(version)/CGAL-$(version)-library.zip")
    add_versions("5.1.1", "ceca7ea896505941878f6c1fb7a7ae86653fdd9b3d87b276da72227f173a9cd2")
    add_versions("5.2.1", "ccdea67db79153417504f50c534cea3bb6b0e9754e7f32fb753fc19005114db0")
    add_versions("5.3", "49ccfb6b72a78d03ab026c6502099ba9358cf604d9d1f51c33e90b314635fe35")
    add_versions("5.4", "dbca692666866df5979ef14264570b85a00f21cb77a9f9420ec0823ce8fae473")
    add_versions("5.5.2", "77b17ba5d43fe844c0eca7fb7eff7d5687174b037290c390f1251ef44cc4909b")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::cgal")
    elseif is_plat("linux") then
        add_extsources("pacman::cgal", "apt::libcgal-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::cgal")
    end

    add_deps("cmake")
    add_deps("boost", "eigen")
    if is_plat("macosx", "linux") then
        add_deps("gmp", "mpfr")
    end

    on_load("windows", "mingw", function (package)
        package:add("defines", "CGAL_NO_GMP")
        if not package:config("header_only") then
            raise("Non-header-only version is not supported yet!")
        end
    end)

    on_install("windows", "mingw", "macosx", "linux", function (package)
        if package:version():le("5.3") then
            io.gsub("CMakeLists.txt", "install%(DIRECTORY.-%/demo%/.-%/demo%/.-%)", "")
        end
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF"}
        table.insert(configs, "-DCGAL_HEADER_ONLY=" .. (package:config("header_only") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            void test() {
                using K = CGAL::Epick_d<CGAL::Dynamic_dimension_tag>;
                using DT = CGAL::Delaunay_triangulation<K>;
                DT::Point p;
                std::vector<DT::Point> points;
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"CGAL/Epick_d.h", "CGAL/Delaunay_triangulation.h"}}))
    end)
