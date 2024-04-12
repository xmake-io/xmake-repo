package("yolov8-onnx")

    set_homepage("https://www.ultralytics.com/yolo")
    set_description("Perform inference using YOLOv8 models with ONNXRuntime.")
    set_license("AGPL-3.0")

    add_configs("cuda_version", {
        description = "Specify which CUDA version to use (11|12), leave blank for no GPU support",
        default = "",
        type = "string"
    })

    set_urls("https://github.com/ultralytics/ultralytics/archive/refs/tags/$(version).tar.gz",
        "https://github.com/ultralytics/ultralytics")
    add_versions("v8.1.0", "4a8b42579f2652bc771a098f7101ce2abb4baf4c88ca3bb4442faed660a48331")

    add_deps("opencv", "onnxruntime")

    on_install(function (package)
        os.cd("examples/YOLOv8-ONNXRuntime-CPP")

        local gpu = package:config("cuda_version") ~= ""
        local cuda_version = package:config("cuda_version")
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            add_requires("opencv ^4.2.0")
            add_requires("onnxruntime ^1.17.0", {configs = {gpu = %s, cuda_version = "%s"}})
            target("yolov8-onnx")
                set_kind("$(kind)")
                add_files("inference.cpp")
                add_headerfiles("inference.h")
                add_packages("opencv", "onnxruntime")
        ]]):format(gpu, cuda_version))
        import("package.tools.xmake").install(package)

        os.cp("inference.h", path.join(package:installdir(), "include/inference.h"))
    end)
