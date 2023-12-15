package("spirv-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/SPIRV-Headers/")
    set_description("SPIR-V Headers")
    set_license("MIT")

    add_urls("https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/$(version).tar.gz", {version = function (version)
        local prefix = "sdk-"
        if version:gt("1.3.261+1") then
            prefix = "vulkan-sdk-"
        end
        return version:startswith("v") and version or prefix .. version:gsub("%+", ".")
    end})

    add_versions("1.2.198+0", "3301a23aca0434336a643e433dcacacdd60000ab3dd35dc0078a297c06124a12")
    add_versions("1.3.211+0", "30a78e61bd812c75e09fdc7a319af206b1044536326bc3e85fea818376a12568")
    add_versions("1.3.231+1", "fc340700b005e9a2adc98475b5afbbabd1bc931f789a2afd02d54ebc22522af3")
    add_versions("1.3.236+0", "4d74c685fdd74469eba7c224dd671a0cb27df45fc9aa43cdd90e53bd4f2b2b78")
    add_versions("1.3.239+0", "fdaf6670e311cd1c08ae90bf813e89dd31630205bc60030ffd25fb0af39b51fe")
    add_versions("1.3.246+1", "71668e18ef7b318b06f8c466f46abad965b2646eaa322594cd015c2ac87133e6")
    add_versions("1.3.250+1", "d5f8c4b7906baf9c51aedbbb2dd942009e8658e3340c6e64699518666a03e043")
    add_versions("1.3.261+1", "32b4c6ae6a2fa9b56c2c17233c8056da47e331f76e117729925825ea3e77a739")
    add_versions("1.3.268+0", "1022379e5b920ae21ccfb5cb41e07b1c59352a18c3d3fdcbf38d6ae7733384d4")

    add_patches("1.3.261+1", "https://github.com/KhronosGroup/SPIRV-Headers/commit/c43effd54686240d8b13762279d5392058d10e27.patch", "b97a05c35c00620519a5f3638a974fc2a01f062bf6e86b74b49a234f82cc55ce")

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
