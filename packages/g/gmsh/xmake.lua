package("gmsh")

    set_homepage("http://gmsh.info/")
    set_description("Gmsh is an open source 3D finite element mesh generator with a built-in CAD engine and post-processor.")
    set_license("GPL-2.0")

    add_urls("http://gmsh.info/src/gmsh-$(version)-source.tgz")
    add_versions("4.8.4", "760dbdc072eaa3c82d066c5ba3b06eacdd3304eb2a97373fe4ada9509f0b6ace")
    add_versions("4.11.1", "c5fe1b7cbd403888a814929f2fd0f5d69e27600222a18c786db5b76e8005b365")

    add_configs("openmp", {description = "Enable OpenMP support.", default = not is_plat("windows"), type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("shell32", "ws2_32", "winmm", "wsock32", "psapi")
    end
    on_load("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "GMSH_DLL")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "add_definitions(-D_USE_MATH_DEFINES)", "add_definitions(-DWIN32)\nadd_definitions(-D_USE_MATH_DEFINES)", {plain = true})
        local configs = {"-DENABLE_TESTS=OFF", "-DENABLE_GMP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_BUILD_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_BUILD_DYNAMIC=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_MSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
        if package:is_plat("windows") and package:config("shared") then
            os.mv(path.join(package:installdir("lib"), "gmsh.dll"), package:installdir("bin"))
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("gmsh -version")
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                gmsh::initialize();
                gmsh::model::add("square");
                int square = gmsh::model::occ::addRectangle(0, 0, 0, 1, 1);
                gmsh::model::occ::synchronize();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "gmsh.h"}))
    end)
