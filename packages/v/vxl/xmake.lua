package("vxl")
    set_homepage("https://github.com/vxl/vxl")
    set_description("A multi-platform collection of C++ software libraries for Computer Vision and Image Understanding.")

    add_urls("https://github.com/vxl/vxl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vxl/vxl.git")
    add_versions("v3.5.0", "f044d2a9336f45cd4586d68ef468c0d9539f9f1b30ceb4db85bd9b6fdb012776")
    add_versions("v3.3.2", "95ecde4b02bbe00aec0d656fd2c43373de2a5d41487a68135f0b565254919411")

    add_configs("contrib", {description = "Build contrib modules.", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "bzip2", "libgeotiff", "libjpeg-turbo", "libpng", "libtiff", "zlib")
    if is_plat("linux") or (is_plat("mingw") and is_subhost("msys")) then
        add_extsources("pacman::vxl")
    end

    add_includedirs("include", "include/vxl/core", "include/vxl/vcl", "include/vxl/v3p")
    add_links("vpgl_xio", "vpgl_io", "vpgl_algo", "vpgl_file_formats", "vpgl", "vpdl", "vcsl", "vil_io", "vgl_xio", "vgl_io", "vnl_xio", "vnl_io", "vbl_io", "vul_io", "vil_algo", "vil", "vil1", "vgl_algo", "vgl", "vnl_algo", "v3p_netlib", "netlib", "testlib", "vnl", "vsl", "vbl", "vul", "vpl", "vcl", "rply", "clipper", "vxl_openjpeg")

    on_install("windows", "linux", "macosx", "bsd", function (package)
        io.replace("config/cmake/Modules/FindGEOTIFF.cmake", "include( ${MODULE_PATH}/NewCMake/FindGEOTIFF.cmake )", "find_package(GeoTIFF CONFIG REQUIRED)", {plain = true})
        io.replace("v3p/openjpeg2/CMakeLists.txt", "set_target_properties(openjpeg2 PROPERTIES", "set_target_properties(openjpeg2 PROPERTIES\n  OUTPUT_NAME   vxl_openjpeg", {plain = true})
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DVXL_BUILD_CONTRIB=" .. (package:config("contrib") and "ON" or "OFF"),
            "-DBUILD_TESTING=OFF",
            "-DVXL_BUILD_EXAMPLES=OFF",
            "-DVXL_USING_NATIVE_BZLIB2=ON",
            "-DVXL_USING_NATIVE_GEOTIFF=ON",
            "-DVXL_USING_NATIVE_JPEG=ON",
            "-DVXL_USING_NATIVE_PNG=ON",
            "-DVXL_USING_NATIVE_TIFF=ON",
            "-DVXL_USING_NATIVE_ZLIB=ON",
        }
        if package:is_plat("windows") and package:is_arch("arm64") and package:is_cross() then
            table.insert(configs, "-DVCL_HAS_LFS=1")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vnl/vnl_matrix.h>
            #include <vnl/vnl_vector.h>
            #include <vil/vil_image_view.h>
            void test() {
                vnl_matrix<double> m(3, 3, 0.0);
                vnl_vector<double> v(3, 1.0);
                vnl_vector<double> r = m * v;
                vil_image_view<unsigned char> image(100, 100, 1);
                image.fill(128);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)