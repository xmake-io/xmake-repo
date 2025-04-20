package("onnxruntime")
    set_homepage("https://www.onnxruntime.ai")
    set_description("ONNX Runtime: cross-platform, high performance ML inferencing and training accelerator")
    set_license("MIT")

    add_configs("gpu", {description = "Enable GPU support on windows|x64 and linux|x86_64", default = false, type = "boolean"})
    add_configs("cuda_version", {description = "Specify which CUDA version to use for GPU support", default = "11", type = "string"})

    if is_plat("windows") then
        if is_arch("x64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x64-$(version).zip")
            add_versions("1.11.1", "1f127b9d41f445a2d03356c86c125cb79dc3e66d391872c9babe6b444a51a93d")
            add_versions("1.15.1", "261308ee5526dfd3f405ce8863e43d624a2e0bcd16b2d33cdea8c120ab3534d3")
            add_versions("1.16.1", "05a972384c73c05bce51ffd3e15b1e78325ea9fa652573113159b5cac547ecce")
            add_versions("1.17.0", "b0436634108c001e2284cb685646047a7b088715b64c05e39ee8a1a8930776a9")
            add_versions("1.17.1", "4802af9598db02153d7da39432a48823ff69b2fb4b59155461937f20782aa91c")
            add_versions("1.19.2", "dc4f841e511977c0a4f02e5066c3d9a58427644010ab4f89b918614a1cd4c2b0")
        elseif is_arch("x86") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x86-$(version).zip")
            add_versions("1.11.1", "734ee4b76a17c466d5a5e628c27c38eccaf512e0228237cfc3d7a0a408986d1c")
            add_versions("1.15.1", "8de18fdf274a8adcd95272fcf58beda0fe2fb37f0cd62c02bc4bb6200429e4e2")
            add_versions("1.16.1", "60b476cde62d424fc9bf87ec3bf275cf40af76bdb25022581f3ecaf4af5992a1")
            add_versions("1.17.0", "3f3214f99165d3282cc5647c5a18451aaaaf326599c7e98913ce6c50e50c6463")
            add_versions("1.17.1", "9404130825474bd36b2538ed925d6b5f2cf1fb6a443f3e125054ae3470019291")
            add_versions("1.19.2", "cffed1d2976ef8cd82b953f9cf1c4332e9d2b05b8270aeb123f7ca90b51cbb4f")
        elseif is_arch("arm64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-arm64-$(version).zip")
            add_versions("1.15.1", "7d9a837c02b1fbed8ee5698e7e18976fe73988df411e97693fd5cf5b09ee0552")
            add_versions("1.17.1", "47782cebcab0fd7a1f0a3f0676b088c1bc0f4fbf21666f6fe57570dc362fa5a8")
            add_versions("1.19.2", "8c0ffad278a65ea72b8c95d008733ec151602031e35f29d6b510b795b13a42fa")
        end
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-x64-$(version).tgz")
            add_versions("1.11.1", "ddc03b5ae325c675ff76a6f18786ce7d310be6eb6f320087f7a0e9228115f24d")
            add_versions("1.15.1", "5492f9065f87538a286fb04c8542e9ff7950abb2ea6f8c24993a940006787d87")
            add_versions("1.16.1", "53a0f03f71587ed602e99e82773132fc634b74c2d227316fbfd4bf67181e72ed")
            add_versions("1.17.0", "efc344d54d1969446ff5d3e55b54e205c6579c06333ecf1d34a04215eefae7c6")
            add_versions("1.17.1", "89b153af88746665909c758a06797175ae366280cbf25502c41eb5955f9a555e")
            add_versions("1.19.2", "eb00c64e0041f719913c4080e0fed7d9963dc3aa9b54664df6036d8308dbcd33")
        elseif is_arch("arm64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-aarch64-$(version).tgz")
            add_versions("1.11.1", "bb9ca658a6a0acc7b9e4288647277a9ce9d86b063a2403a51d5c0d2e4df43603")
            add_versions("1.15.1", "85272e75d8dd841138de4b774a9672ea93c1be108d96038c6c34a62d7f976aee")
            add_versions("1.16.1", "f10851b62eb44f9e811134737e7c6edd15733d2c1549cb6ce403808e9c047385")
            add_versions("1.17.0", "ee5069252f549ef94759b6b60bdf10b2dc2cd71d064a7045dd66a052f956a68b")
            add_versions("1.17.1", "70b6f536bb7ab5961d128e9dbd192368ac1513bffb74fe92f97aac342fbd0ac1")
            add_versions("1.19.2", "5e30145277d6d6fcb0e8f14f0d0ab5048af7b13ffd608023bb1e2875621fab07")
        end
    elseif is_plat("macosx") then
        if is_arch("x86_64") then
            add_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-osx-x86_64-$(version).tgz")
            add_versions("1.11.1", "872e4413d73382db14e892112a0ee319746420f7f3a38121038a2845a97e7b5b")
            add_versions("1.15.1", "4b66ebbca24b8b96f6b74655fee3610a7e529b4e01f6790632f24ee82b778e5a")
            add_versions("1.16.1", "0b8ae24401a8f75e1c4f75257d4eaeb1b6d44055e027df4aa4a84e67e0f9b9e3")
            add_versions("1.17.0", "b87b2febef24e5645e13859d176e76473124325a0b1526baf7f68b4aa1eb1b49")
            add_versions("1.17.1", "86c6b6896434084ff5086eebc4e9ea90be1ed4d46743f92864f46ee43e7b5059")
            add_versions("1.19.2", "6536e36d7ea92e32d53dad7ddd0fdf10be5b62d1dace85a13e1295ff81e9b5d4")
        elseif is_arch("arm64") then
            add_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-osx-arm64-$(version).tgz")
            add_versions("1.11.1", "dc70af1424f173d57477ecf902d4bf4a2d3a110167089037e3866ac2bf3182e3")
            add_versions("1.15.1", "df97832fc7907c6677a6da437f92339d84a462becb74b1d65217fcb859ee9460")
            add_versions("1.16.1", "56ca6b8de3a220ea606c2067ba65d11dfa6e4f722e01ac7dc75f7152b81445e0")
            add_versions("1.17.0", "f72a2bcca40e2650756c6b96c69ef031236aaab1b98673e744da4eef0c4bddbd")
            add_versions("1.17.1", "89566f424624a7ad9a7d9d5e413c44b9639a994d7171cf409901d125b16e2bb3")
            add_versions("1.19.2", "370c49770e2e1f243e17c7b227bb7f4b3da793b847d02f38016dc0e46c30fbe1")
        end
    end

    on_load(function (package)
        if package:config("gpu") then
            package:add("deps", "cuda", {configs = {utils = {"cudart", "nvrtc"}}})

            local versions = package:get("versions")
            if package:is_plat("windows") and package:is_arch("x64") then
                versions["1.11.1"] = "a9a10e76fbb4351d4103a4d46dc37690075901ef3bb7304dfa138820c42c547b"
                versions["1.15.1"] = "dcc3a385b415dd2e4a813018b71da5085d9b97774552edf17947826a255a3732"
                versions["1.16.1"] = "b841f8e8d9a0556bfc5228ff1488395fa041fafe8d16a62e25a254d000d51888"
                versions["1.19.2"] = "c04c6342b9e351d2ec7ebd84ce08f3ea4f20706993b40172234c535ace25f629"
                if package:config("cuda_version") == "12" then
                    versions["1.17.0"] = "63823f29039e593da435a6af6757949262ac592e575bfe08675a11d4963b47cf"
                    versions["1.17.1"] = "5c6e1433d63e699d97d66d66427830caf5e69ea077569bc1e2ab5e1450d8fac1"
                    package:set("urls", "https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x64-cuda12-$(version).zip")
                else
                    versions["1.17.0"] = "3c90a38769e2f7bdb088c00410de4895b07b7d53a7c80955f18989775c2a25e7"
                    versions["1.17.1"] = "b7a66f50ad146c2ccb43471d2d3b5ad78084c2d4ddbd3ea82d65f86c867408b2"
                    package:set("urls", "https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x64-gpu-$(version).zip")
                end
            elseif package:is_plat("linux") and package:is_arch("x86_64") then
                versions["1.11.1"] = "31c392b5804a57bbcf2550a29a76af8641bfbd8a0f68b7e354d876689fe667f2"
                versions["1.15.1"] = "eab891393025edd5818d1aa26a42860e5739fcc49e3ca3f876110ec8736fe7f1"
                versions["1.16.1"] = "474d5d74b588d54aa3e167f38acc9b1b8d20c292d0db92299bdc33a81eb4492d"
                versions["1.19.2"] = "4d1c10f0b410b67261302c6e18bb1b05ba924ca9081e3a26959e0d12ab69f534"
                if package:config("cuda_version") == "12" then
                    versions["1.17.0"] = "0f0b9a6e7ba703c095aae19220d14f7c48c6170ed24ebf6bc97fbde01312985f"
                    versions["1.17.1"] = "3a7b114545a90d65ed01d42faabc08f735c1bb58d9065d423c6e4a89222b4efc"
                    package:set("urls", "https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-x64-cuda12-$(version).tgz")
                else
                    versions["1.17.0"] = "27cfa22af7301868b55220f8733361889286b30be0569a8f46abb63e90342180"
                    versions["1.17.1"] = "613c53745ea4960ed368f6b3ab673558bb8561c84a8fa781b4ea7fb4a4340be4"
                    package:set("urls", "https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-x64-gpu-$(version).tgz")
                end
            end
            package:set("versions", versions)
        end
    end)

    on_install("windows", "linux|arm64", "linux|x86_64", "macosx", function (package)
        if package:is_plat("windows") then
            os.mv("lib/*.dll", package:installdir("bin"))
        end
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <array>
            #include <cstdint>
            void test() {
                std::array<float, 2> data = {0.0f, 0.0f};
                std::array<int64_t, 1> shape{2};

                Ort::Env env;

                auto memory_info = Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU);
                auto tensor = Ort::Value::CreateTensor<float>(memory_info, data.data(), data.size(), shape.data(), shape.size());
            }
        ]]}, {configs = {languages = "c++17"}, includes = "onnxruntime_cxx_api.h"}))
    end)
