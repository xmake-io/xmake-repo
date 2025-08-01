package("vcglib")

    set_kind("library", {headeronly = true})
    set_homepage("http://www.vcglib.net/")
    set_description("The Visualization and Computer Graphics Library (VCG for short) is a open source portable C++ templated library for manipulation, processing and displaying with OpenGL of triangle and tetrahedral meshes.")
    set_license("GPL-3.0")

    add_urls("https://github.com/cnr-isti-vclab/vcglib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cnr-isti-vclab/vcglib.git")
    add_versions("2025.07", "e49fc9342d5476b3e39a5e1939b965b57c91d7a17b4f97b8c5eaf01228b16cf0")
    add_versions("2023.12", "5a84db6d596be1cb4abdc450d130dc8e2224a4c7b4198b60cd9ac55f45ac5c7b")
    add_versions("2020.12", "731c57435e39c4b958a1d766cadd9865d9db35e36410708f2da7818e9fa5f786")
    add_versions("2021.07", "384bb4bb86b4114391cbc0fb8990f218473a656d06f2214bcc3725dac193db1c")
    add_versions("2021.10", "a443a4a63c0f6691229c80aa22a15f17ab7d9da2b0b6a5111cf39aee86632d5a")
    add_versions("2022.02", "724f5ef6ab9b9d21ff2e9e965c2ce909cc024b29f2aa7d39e2974b28ff25bc3f")

    add_deps("eigen")
    on_install("windows", "macosx", "linux", function (package)
        os.mv("apps", package:installdir("include"))
        os.mv("eigenlib", package:installdir("include"))
        os.mv("vcg", package:installdir("include"))
        os.mv("wrap", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                vcg::Quaternionf q(1, 0, 0, 0);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "vcg/math/quaternion.h"}))
    end)
