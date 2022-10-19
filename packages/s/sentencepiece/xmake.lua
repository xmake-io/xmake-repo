package("sentencepiece")

    set_homepage("https://github.com/google/sentencepiece")
    set_description("Unsupervised text tokenizer for Neural Network-based text generation. .")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/sentencepiece/archive/$(version).tar.gz",
             "https://github.com/google/sentencepiece.git")

    add_versions("v0.1.97", "58f256cf6f01bb86e6fa634a5cc560de5bd1667d")


    add_deps("cmake", "gperftools")

    add_configs("external_abseil", {description = "Use external abseil.", default = false, type = "boolean"})
    add_configs("builtin_protobuf", {description = "Use built-in protobuf.", default = true, type = "boolean"})

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

        if package:is_plat("windows") and package:config("shared") then
            -- Shared build is impossible on windows
            -- https://github.com/google/sentencepiece/issues/785
            print("Shared build is impossible on windows. Roll back to static")
            package:config_set("shared", false)
        end


        table.insert(configs, "-DSPM_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSPM_USE_EXTERNAL_ABSL=" .. (package:config("external_abseil") and "ON" or "OFF"))
        table.insert(configs, "-DSPM_USE_BUILTIN_PROTOBUF=" .. (package:config("builtin_protobuf") and "ON" or "OFF"))


        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("sentencepiece::SentencePieceProcessor", {includes = "sentencepiece_processor.h",configs = {languages = "cxx17"}}))
    end)
