package("vcglib")

    set_homepage("http://www.vcglib.net/")
    set_description("The Visualization and Computer Graphics Library (VCG for short) is a open source portable C++ templated library for manipulation, processing and displaying with OpenGL of triangle and tetrahedral meshes.")
    set_license("GPL-3.0")

    add_urls("https://github.com/cnr-isti-vclab/vcglib/archive/refs/tags/2020.12.tar.gz")
    add_versions("2020.12", "731c57435e39c4b958a1d766cadd9865d9db35e36410708f2da7818e9fa5f786")

    add_deps("eigen")
    on_install("windows", "macosx", "linux", function (package)
        os.mv("vcg", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                vcg::Quaternionf q(1, 0, 0, 0);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "vcg/math/quaternion.h"}))
    end)
