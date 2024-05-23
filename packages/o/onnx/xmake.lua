package("onnx")
    set_homepage("https://onnx.ai/")
    set_description("Open standard for machine learning interoperability")
    set_license("Apache-2.0")

    add_urls("https://github.com/onnx/onnx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/onnx/onnx.git")
    add_versions("v1.16.0", "0ce153e26ce2c00afca01c331a447d86fbf21b166b640551fe04258b4acfc6a4")
    add_versions("v1.15.0", "c757132e018dd0dd171499ef74fca88b74c5430a20781ec53da19eb7f937ef68")
    add_versions("v1.11.0", "a20f2d9df805b16ac75ab4da0a230d3d1c304127d719e5c66a4e6df514e7f6c0")
    add_versions("v1.12.0", "052ad3d5dad358a33606e0fc89483f8150bb0655c99b12a43aa58b5b7f0cc507")

    add_deps("cmake")
    add_deps("protobuf-cpp")
    add_deps("python", {kind = "binary"})

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load("linux", "macosx", "windows", function (package)
        package:add("defines", "ONNX_ML")
        package:add("defines", "ONNX_NAMESPACE=onnx")
    end)

    on_install("linux", "macosx", "windows|x64", "windows|x86", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_CXX_STANDARD=17")
        if package:is_plat("windows") then
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime then
                table.insert(configs, "-DONNX_USE_MSVC_STATIC_RUNTIME=" .. (vs_runtime:startswith("MT") and "ON" or "OFF"))
            end
            if package:config("shared") then
                package:add("defines", "PROTOBUF_USE_DLLS")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package) assert(package:has_cxxtypes("onnx::ModelProto", {includes = "onnx/proto_utils.h", configs = {languages = "c++17"}}))
    end)
