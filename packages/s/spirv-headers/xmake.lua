package("spirv-headers")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/SPIRV-Headers/")
    set_description("SPIR-V Headers")
    set_license("MIT")

    add_urls("https://github.com/KhronosGroup/SPIRV-Headers/archive/$(version).tar.gz", {version = function (version) return version:startswith("v") and version or "sdk-" .. version:gsub("%+", ".") end})
    add_versions("1.2.198+0", "3301a23aca0434336a643e433dcacacdd60000ab3dd35dc0078a297c06124a12")
    add_versions("1.3.211+0", "30a78e61bd812c75e09fdc7a319af206b1044536326bc3e85fea818376a12568")
    add_versions("1.3.224+1", "c85714bfe62f84007286bd3b3c0471af0a7e06ab66bc2ca4623043011b28737f")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DSPIRV_HEADERS_SKIP_EXAMPLES=ON"})
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = SPV_VERSION;
            }
        ]]}, {includes = "spirv/unified1/spirv.h"}))
    end)
