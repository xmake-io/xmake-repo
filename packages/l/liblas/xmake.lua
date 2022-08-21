package("liblas")

    set_homepage("https://liblas.org/index.html")
    set_description("libLAS - LAS 1.0/1.1/1.2 ASPRS LiDAR data translation toolset")
    set_license("BSD-3-Clause")

    add_urls("http://download.osgeo.org/liblas/libLAS-$(version).tar.bz2")
    add_versions("1.8.1", "9adb4a98c63b461ed2bc82e214ae522cbd809cff578f28511122efe6c7ea4e76")

    add_patches("1.8.1", path.join(os.scriptdir(), "patches", "1.8.1", "header.patch"), "fde1c186e78472f4eb8902f28b51b18a8b40166379c710b43f89323aac7c3afd")

    add_deps("cmake", "libgeotiff")
    add_deps("boost", {configs = {program_options = true,
                                  thread = true,
                                  system = true,
                                  iostreams = true,
                                  filesystem = true}})
    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "JPEG", "PROJ", {plain = true})
        io.replace("src/CMakeLists.txt", "${GDAL_LIBRARY}", "${PROJ_LIBRARIES}", {plain = true})
        local configs = {"-DWITH_TESTS=OFF", "-DWITH_LASZIP=OFF", "-DWITH_GDAL=OFF", "-DBUILD_OSGEO4W=OFF", "-DBoost_USE_STATIC_LIBS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <liblas/liblas.hpp>
            #include <fstream>
            void test() {
                std::ifstream ifs;
                ifs.open("file.las", std::ios::in | std::ios::binary);
                liblas::ReaderFactory f;
                liblas::Reader reader = f.CreateWithStream(ifs);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
