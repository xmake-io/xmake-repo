package("yolov5-onnx")

    set_homepage("https://www.ultralytics.com/yolo")
    set_description("Perform inference using YOLOv5 models with ONNXRuntime.")
    set_license("AGPL-3.0")

    add_configs("cuda_version", {
        description = "Specify which CUDA version to use (11|12), leave blank for no GPU support",
        default = "",
        type = "string"
    })

    local version_hashes = {
        ["v0.1.0"] = "6c1b10db80a98a53421021f2dccc46a73f5613b5"
    }
    set_urls("https://github.com/junchao98/yolov5-onnxruntime/archive/$(version).tar.gz",
        "https://github.com/junchao98/yolov5-onnxruntime",
        {version = function (version) return version_hashes[tostring(version)] end})
    add_versions("v0.1.0", "3fb9773284562f34e3cc082438ff270b9f5106fa657e482423b86e87c779967a")

    add_deps("opencv", "onnxruntime")
    
    on_install(function (package)
        os.rm("include/cmdline.h")

        local gpu = package:config("cuda_version") ~= ""
        local cuda_version = package:config("cuda_version")
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            add_requires("opencv ^4.2.0")
            add_requires("onnxruntime ^1.17.0", {configs = {gpu = %s, cuda_version = "%s"}})
            target("yolov5-onnx")
                set_kind("$(kind)")
                add_files("src/*.cpp|main.cpp")
                add_includedirs("include")
                add_packages("opencv", "onnxruntime")
        ]]):format(gpu, cuda_version))
        import("package.tools.xmake").install(package)

        os.cp("include/*.h", path.join(package:installdir(), "include"))
    end)

