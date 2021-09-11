package("spirv-headers")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/SPIRV-Headers/")
    set_description("SPIR-V Headers")
    set_license("MIT")

    local map = {["1.5.4+2"] = "1.5.4.raytracing.fixed",
                 -- Workaround since no new releases are available for spirv-headers, will be removed in future
                 ["1.5.5"] = "e71feddb3f17c5586ff7f4cfb5ed1258b800574b"}
    add_urls("https://github.com/KhronosGroup/SPIRV-Headers/archive/$(version).tar.gz", {version = function (version) return map[tostring(version)] end})
    add_versions("1.5.4+2", "df2ad2520be4d95a479fa248921065885bbf435a658349a7fc164ad7b26b68c6")
    add_versions("1.5.5", "9eb56548460fd8850250ebf78071528fb66c2a5db2ef535edc1d493b2581ec66")

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
