package("onnx")
    set_homepage("https://onnx.ai/")
    set_description("Open standard for machine learning interoperability")
    set_license("Apache-2.0")

    add_urls("https://github.com/onnx/onnx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/onnx/onnx.git")
    add_versions("v1.11.0", "a20f2d9df805b16ac75ab4da0a230d3d1c304127d719e5c66a4e6df514e7f6c0")
    add_versions("v1.12.0", "052ad3d5dad358a33606e0fc89483f8150bb0655c99b12a43aa58b5b7f0cc507")

    add_deps("cmake")
    add_deps("protobuf-cpp")

    on_load("linux", "macosx", "windows", function (package)
        package:add("defines", "ONNX_ML")
        package:add("cxxflags", "-DONNX_NAMESPACE=onnx")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("onnx::ModelProto", {includes = "onnx/proto_utils.h"}))
    end)
