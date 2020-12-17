package("spirv-headers")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Headers/")
    set_description("SPIR-V Headers")
    set_license("MIT")

    local map = {["1.5.4+2"] = "1.5.4.raytracing.fixed"}
    add_urls("https://github.com/KhronosGroup/SPIRV-Headers/archive/$(version).tar.gz", {version = function (version) return map[tostring(version)] end})
    add_versions("1.5.4+2", "df2ad2520be4d95a479fa248921065885bbf435a658349a7fc164ad7b26b68c6")

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
