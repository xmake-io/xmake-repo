package("sentencepiece")

    set_homepage("https://github.com/google/sentencepiece")
    set_description("Unsupervised text tokenizer for Neural Network-based text generation. .")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/sentencepiece/archive/$(version).tar.gz",
             "https://github.com/google/sentencepiece.git")

    add_versions("v0.1.97", "41c3a07f315e3ac87605460c8bb8d739955bc8e7f478caec4017ef9b7d78669b")

    add_deps("cmake", "gperftools")

    add_configs("external_abseil",  {description = "Use external abseil.", default = false, type = "boolean"})
    add_configs("builtin_protobuf", {description = "Use built-in protobuf.", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared",     {description = "Build shared library.", default = false, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT", readonly = true})
    end

    on_load("windows", "linux", "macosx",function (package)
        if package:config("external_abseil") then
            package:add("deps", "abseil")
        end
        if not package:config("builtin_protobuf") then
            package:add("deps", "protobuf-cpp")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DSPM_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSPM_USE_EXTERNAL_ABSL=" .. (package:config("external_abseil") and "ON" or "OFF"))
        table.insert(configs, "-DSPM_USE_BUILTIN_PROTOBUF=" .. (package:config("builtin_protobuf") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
