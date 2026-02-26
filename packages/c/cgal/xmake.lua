package("cgal")

    set_homepage("https://www.cgal.org/")
    set_description("CGAL is a software project that provides easy access to efficient and reliable geometric algorithms in the form of a C++ library.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/CGAL/cgal/releases/download/v$(version)/CGAL-$(version)-library.zip")
    add_versions("6.1.1", "6c5d68be1d28cbee3c3e05003746ec4791d0018c770b4276b9e6d69c3a0a355a")
    add_versions("6.1", "d129a47329e7811b31b7343901fdb7b64d029b0cce262405fbebacd11f9b00dd")
    add_versions("6.0.2", "5cda4d2490c9cc2cd8d7a4b87ca0ea2ef319724e728f761f55e09bc2394249b2")
    add_versions("6.0", "f4a66cf4e276a377d263ee3db627919d1000e29bf24664a5d0b8cb82081ef706")
    add_versions("5.6.1", "cf3900280d96847db8ac5e174d5e889f9764c7fa4e3d99f316f89910058335e6")
    add_versions("5.1.1", "ceca7ea896505941878f6c1fb7a7ae86653fdd9b3d87b276da72227f173a9cd2")
    add_versions("5.2.1", "ccdea67db79153417504f50c534cea3bb6b0e9754e7f32fb753fc19005114db0")
    add_versions("5.3", "49ccfb6b72a78d03ab026c6502099ba9358cf604d9d1f51c33e90b314635fe35")
    add_versions("5.4", "dbca692666866df5979ef14264570b85a00f21cb77a9f9420ec0823ce8fae473")
    add_versions("5.5.2", "77b17ba5d43fe844c0eca7fb7eff7d5687174b037290c390f1251ef44cc4909b")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})
    add_configs("gmp", {description = "Use gmp/mpfr.", default = is_plat("macosx", "linux"), type = "boolean"})
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::cgal")
    elseif is_plat("linux") then
        add_extsources("pacman::cgal", "apt::libcgal-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::cgal")
    end

    add_deps("cmake")
    add_deps("eigen")
    add_deps("boost", {configs = {
        accumulators = true, algorithm = true, bimap = true, callable_traits = true, concept_check = true,
        container = true, core = true, detail = true, filesystem = true, format = true, functional = true,
        fusion = true, geometry = true, graph = true, heap = true, intrusive = true, iostreams = true,
        iterator = true, lambda = true, logic = true, math = true, mpl = true, multi_array = true,
        multi_index = true, multiprecision = true, numeric_conversion = true, optional = true,
        parameter = true, pool = true, preprocessor = true, property_map = true, property_tree = true,
        ptr_container = true, random = true, range = true, serialization = true, spirit = true,
        thread = true, tuple = true, type_traits = true, units = true, utility = true, variant = true}})
    on_check("windows", "mingw", function (package)
        if not package:config("header_only") and (package:version():lt("6.0") or package:config("gmp")) then
            raise("GMP is not supported on windows yet!")
        end
    end)

    on_load("windows", "mingw", "macosx", "linux", function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        end
        if package:config("gmp") then
            package:add("deps", "gmp", "mpfr")
        else
            package:add("defines", "CGAL_DISABLE_GMP")
            package:add("defines", "CGAL_NO_GMP")
        end
    end)

    on_install("windows", "mingw", "macosx", "linux", function (package)
        if package:version():le("5.3") then
            io.gsub("CMakeLists.txt", "install%(DIRECTORY.-%/demo%/.-%/demo%/.-%)", "")
        end
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF"}
        table.insert(configs, "-DCGAL_HEADER_ONLY=" .. (package:config("header_only") and "ON" or "OFF"))
        table.insert(configs, "-DCGAL_DISABLE_GMP=" .. (package:config("gmp") and "OFF" or "ON"))
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
        ]]}, {configs = {languages = "c++17"}, includes = {"CGAL/Epick_d.h", "CGAL/Delaunay_triangulation.h"}}))
    end)
