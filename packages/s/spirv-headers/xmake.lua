package("spirv-headers")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Headers/")
    set_description("SPIR-V Headers")
    set_license("MIT")

    add_urls("https://github.com/KhronosGroup/SPIRV-Headers/archive/$(version).tar.gz")
    add_versions("1.5.4", "fc026b6566167f6db03dc48779f0f986f9ff8c93ed651a557f28cfbe2dff4ede")

    add_deps("cmake")

    on_install("linux", "windows", "macosx", function (package)
        import("package.tools.cmake").install(package, {"-DSPIRV_HEADERS_SKIP_EXAMPLES=ON"})
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = SPV_VERSION;
            }
        ]]}, {includes = "spirv/unified1/spirv.h"}))
    end)
