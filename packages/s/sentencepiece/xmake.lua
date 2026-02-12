package("sentencepiece")
    set_homepage("https://github.com/google/sentencepiece")
    set_description("Unsupervised text tokenizer for Neural Network-based text generation. .")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/sentencepiece/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/sentencepiece.git")

    add_versions("v0.2.0", "9970f0a0afee1648890293321665e5b2efa04eaec9f1671fcf8048f456f5bb86")
    add_deps("cmake", "abseil", "protobuf-cpp", "gperftools")
 
    add_patches("v0.2.0", "patches/v0.2.0/absl-cmake-fix.patch", "8fcbe6f4b49972e624b1d61627d36c16e13946b168dd001b138e511febbc7ca4")

    on_install("windows|!arm*", "linux", "macosx", function (package)
        -- replace abseil third_party include path by <absl/...>
        for _, file in ipairs(os.files("src/**.cc")) do
            io.replace(file, [["third_party/absl/(.-)"]], [[<absl/%1>]])
        end
        for _, file in ipairs(os.files("src/**.h")) do
            io.replace(file, [["third_party/absl/(.-)"]], [[<absl/%1>]])
        end

        -- add missing include
        io.replace("src/sentencepiece_processor.h", "#include <cstring>", "#include <cstring>\n#include <cstdint>", {plain = true})

        local configs = {}
        table.insert(configs, "-DSPM_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSPM_ABSL_PROVIDER=package")
        table.insert(configs, "-DSPM_PROTOBUF_PROVIDER=package")
        import("package.tools.cmake").install(package, configs, {packagedeps = {"abseil", "protobuf-cpp"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(int args, char** argv) {
                sentencepiece::SentencePieceProcessor processor;
                const auto status = processor.Load("//path/to/model.model");
                if (!status.ok()) {
                    std::cerr << status.ToString() << std::endl;
                }
            }
        ]]}, {configs = {languages = "c++17"}, includes = "sentencepiece_processor.h"}))
    end)
