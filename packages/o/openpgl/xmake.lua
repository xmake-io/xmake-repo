package("openpgl")

    set_homepage("http://www.openpgl.org/")
    set_description("Intel(R) Open Path Guiding Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/OpenPathGuidingLibrary/openpgl/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/OpenPathGuidingLibrary/openpgl.git")

    add_versions("0.5.0", "1ec806d434d45e43e098f82ee9be0cb74928343898c57490b34ff80584e9805a")

    add_configs("avx512", {description = "Enable AVX512", default = false, type = "boolean"})
    add_configs("neon",   {description = "Enable NEON", default = false, type = "boolean"})
    add_configs("neon2x", {description = "Enable double pumped NEON", default = false, type = "boolean"})

    add_deps("cmake", "tbb", "embree")

    on_install("linux", "windows|x64", "windows|x86", function (package)
        local configs = {}
        if package:config("avx512") then
            table.insert(configs, "-DOPENPGL_ISA_AVX512=ON")
        end
        if package:config("neon") then
            table.insert(configs, "-DOPENPGL_ISA_NEON=ON")
        end
        if package:config("neon2x") then
            table.insert(configs, "-DOPENPGL_ISA_NEON2X=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DOPENPGL_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("openpgl/cpp/OpenPGL.h"))
    end)
