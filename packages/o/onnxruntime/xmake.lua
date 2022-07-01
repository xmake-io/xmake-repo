package("onnxruntime")
    set_homepage("https://www.onnxruntime.ai")
    set_description("ONNX Runtime: cross-platform, high performance ML inferencing and training accelerator")
    set_license("MIT")

    if is_plat("windows") then
        if is_arch("x64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x64-$(version).zip")
            add_versions("1.11.1", "1f127b9d41f445a2d03356c86c125cb79dc3e66d391872c9babe6b444a51a93d")
        elseif is_arch("x86") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x86-$(version).zip")
            add_versions("1.11.1", "734ee4b76a17c466d5a5e628c27c38eccaf512e0228237cfc3d7a0a408986d1c")
        end
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-x64-$(version).tgz")
            add_versions("1.11.1", "ddc03b5ae325c675ff76a6f18786ce7d310be6eb6f320087f7a0e9228115f24d")
        elseif is_arch("arm64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-aarch64-$(version).tgz")
            add_versions("1.17.6", "bb9ca658a6a0acc7b9e4288647277a9ce9d86b063a2403a51d5c0d2e4df43603")
        end
    elseif is_plat("macosx") then
        if is_arch("x86_64") then
            add_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-osx-x86_64-$(version).tgz")
            add_versions("1.11.1", "872e4413d73382db14e892112a0ee319746420f7f3a38121038a2845a97e7b5b")
        elseif is_arch("arm64") then
            add_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-osx-arm64-$(version).tgz")
            add_versions("1.11.1", "dc70af1424f173d57477ecf902d4bf4a2d3a110167089037e3866ac2bf3182e3")
        end
    end

    on_install("windows", "linux|arm64", "linux|x86_64", "macosx", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <array>

            void test() {
                std::array<float, 2> data = {0.0f, 0.0f};
                std::array<std::int64_t, 1> shape{2};

                Ort::Env env;

                auto memory_info = Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU);
                auto tensor = Ort::Value::CreateTensor<float>(memory_info, data.data(), data.size(), shape.data(), shape.size());
            }
        ]]}, {configs = {languages = "c++17"}, includes = "onnxruntime_cxx_api.h"}))
    end)
