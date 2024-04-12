package("rapidocr-onnx")

    set_homepage("https://github.com/RapidAI/RapidOCR")
    set_description("Awesome OCR toolkit based on ONNXRuntime, OpenVINO and PaddlePaddle.")
    set_license("Apache-2.0")

    add_configs("cuda_version", {
        description = "Specify which CUDA version to use (11|12), leave blank for no GPU support",
        default = "",
        type = "string"
    })

    set_urls("https://github.com/RapidAI/RapidOcrOnnx/archive/refs/tags/$(version).tar.gz",
        "https://github.com/RapidAI/RapidOcrOnnx.git")
    add_versions("1.2.3", "99f2bdd0d7198a7d1613291ad3c00fead7ee5f708c2ceb94331401693f3ff865")

    add_deps("opencv", "onnxruntime")

    on_install(function (package)
        os.cd("include")
        for _, file in ipairs({"getopt.h", "main.h", "OcrLiteCApi.h", "OcrResultUtils.h", "version.h"}) do
            os.rm(file)
        end
        for _, file in ipairs(os.files("*.h")) do
            io.replace(file, "<onnxruntime/core/session/onnxruntime_cxx_api.h>", "<onnxruntime_cxx_api.h>")
        end
        os.cd("..")

        local gpu = package:config("cuda_version") ~= ""
        local cuda_version = package:config("cuda_version")
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            add_requires("opencv ^4.6.0")
            add_requires("onnxruntime ^1.17.0", {configs = {gpu = %s, cuda_version = "%s"}})
            target("rapidocr-onnx")
                set_kind("$(kind)")
                add_files("src/*.cpp|main.cpp|getopt.cpp|OcrLiteJni.cpp|OcrLiteCApi.cpp|OcrResultUtils.cpp")
                add_includedirs("include")
                add_packages("opencv", "onnxruntime")
        ]]):format(gpu, cuda_version))
        import("package.tools.xmake").install(package)

        os.cp("include/*.h", path.join(package:installdir(), "include"))
        os.cp("include/*.hpp", path.join(package:installdir(), "include"))
    end)
