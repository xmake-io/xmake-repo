package("yolos-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Geekgineer/YOLOs-CPP")
    set_description("Cross-Platform Production-ready C++ inference engine for YOLO models (v5-v12, YOLO26).")
    set_license("AGPL-3.0")

    add_urls("https://github.com/Geekgineer/YOLOs-CPP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Geekgineer/YOLOs-CPP.git")
    add_versions("v1.1.0", "d764a13a8e51b43101251595536b0a96dce30d5d13c8c688eb64e4ee71392338")
    add_versions("v1.0.0", "2be86dbd0344468f03afab473865171c49e65561d13b00a5ef91e294c218c556")

    add_configs("gpu", {description = "Enable GPU support.", default = false, type = "boolean"})

    on_load(function (package)
        package:add("deps", "onnxruntime", {configs = {gpu = package:config("gpu")}})
        package:add("deps", "opencv")
    end)

    on_install("windows", "linux|arm64", "linux|x86_64", "macosx", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("yolos::version::toString(yolos::YOLOVersion::Auto)", {includes = {"yolos/yolos.hpp"}, configs = {languages = "c++17"}}))
    end)
