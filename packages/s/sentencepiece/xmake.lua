package("sentencepiece")

    set_homepage("https://github.com/google/sentencepiece")
    set_description("Unsupervised text tokenizer for Neural Network-based text generation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/sentencepiece/archive/$(version).tar.gz",
             "https://github.com/google/sentencepiece.git")

    add_versions("v0.2.1", "c1a59e9259c9653ad0ade653dadff074cd31f0a6ff2a11316f67bee4189a8f1b")
    add_versions("v0.2.0", "9970f0a0afee1648890293321665e5b2efa04eaec9f1671fcf8048f456f5bb86")
    add_versions("v0.1.99", "63617eaf56c7a3857597dcd8780461f57dd21381b56a27716ef7d7e02e14ced4")
    add_versions("v0.1.97", "41c3a07f315e3ac87605460c8bb8d739955bc8e7f478caec4017ef9b7d78669b")

    add_deps("cmake")

    add_configs("external_abseil",  {description = "Use external abseil.", default = false, type = "boolean"})
    add_configs("builtin_protobuf", {description = "Use built-in protobuf.", default = true, type = "boolean"})
    add_configs("tcmalloc",         {description = "Use tcmalloc (gperftools) for better memory allocation performance.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load("windows", "linux", "macosx", function (package)
        if package:config("external_abseil") then
            package:add("deps", "abseil")
        end
        if not package:config("builtin_protobuf") then
            package:add("deps", "protobuf-cpp")
        end
        if package:config("tcmalloc") then
            package:add("deps", "gperftools")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        -- Fix missing #include <cstdint> in versions < v0.2.1 (added upstream in v0.2.1)
        if package:version() and package:version():lt("0.2.1") then
            io.replace("src/sentencepiece_processor.h",
                "#include <cstring>",
                "#include <cstring>\n#include <cstdint>",
                {plain = true})
        end

        local configs = {
            "-DSPM_BUILD_TEST=OFF",
        }
        table.insert(configs, "-DSPM_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSPM_ENABLE_TCMALLOC=" .. (package:config("tcmalloc") and "ON" or "OFF"))

        -- v0.2.0+ replaced SPM_USE_BUILTIN_PROTOBUF / SPM_USE_EXTERNAL_ABSL with
        -- SPM_PROTOBUF_PROVIDER ("internal" | "package") and
        -- SPM_ABSL_PROVIDER    ("internal" | "module" | "package")
        if package:version() and package:version():ge("0.2.0") then
            table.insert(configs, "-DSPM_PROTOBUF_PROVIDER=" .. (package:config("builtin_protobuf") and "internal" or "package"))
            table.insert(configs, "-DSPM_ABSL_PROVIDER=" .. (package:config("external_abseil") and "package" or "internal"))
        else
            table.insert(configs, "-DSPM_USE_BUILTIN_PROTOBUF=" .. (package:config("builtin_protobuf") and "ON" or "OFF"))
            table.insert(configs, "-DSPM_USE_EXTERNAL_ABSL=" .. (package:config("external_abseil") and "ON" or "OFF"))
        end

        local packagedeps = {}
        if package:config("external_abseil") then
            table.insert(packagedeps, "abseil")
        end
        if not package:config("builtin_protobuf") then
            table.insert(packagedeps, "protobuf-cpp")
        end
        if package:config("tcmalloc") then
            table.insert(packagedeps, "gperftools")
            -- Patch CMakeLists to append libcommon.a immediately after libtcmalloc_minimal.a in SPM_LIBS
            io.replace("src/CMakeLists.txt",
                "list(APPEND SPM_LIBS ${TCMALLOC_LIB})",
                "list(APPEND SPM_LIBS ${TCMALLOC_LIB})\n    find_library(TCMALLOC_COMMON_LIB NAMES libcommon.a)\n    if (TCMALLOC_COMMON_LIB)\n      list(APPEND SPM_LIBS ${TCMALLOC_COMMON_LIB})\n    endif()",
                {plain = true})
            table.insert(configs, "-DSPM_TCMALLOC_STATIC=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test() {
                sentencepiece::SentencePieceProcessor processor;
                const auto status = processor.Load("path/to/model.model");
                if (!status.ok()) {
                    std::cerr << status.ToString() << std::endl;
                }
            }
        ]]}, {configs = {languages = "c++17"}, includes = "sentencepiece_processor.h"}))
    end)
