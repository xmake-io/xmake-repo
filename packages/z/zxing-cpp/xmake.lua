package("zxing-cpp")
    set_homepage("https://github.com/zxing-cpp/zxing-cpp")
    set_description("C++ port of ZXing")
    set_license("Apache-2.0")

    add_urls("https://github.com/zxing-cpp/zxing-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zxing-cpp/zxing-cpp.git")

    add_versions("v2.3.0", "64e4139103fdbc57752698ee15b5f0b0f7af9a0331ecbdc492047e0772c417ba")
    add_versions("v2.2.1", "02078ae15f19f9d423a441f205b1d1bee32349ddda7467e2c84e8f08876f8635")

    add_configs("c_api", {description = "Build C API", default = false, type = "boolean"})
    add_configs("experimental", {description = "Build with experimental API", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_C_API=OFF", "-DBUILD_DEPENDENCIES=LOCAL"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_EXPERIMENTAL_API=" .. (package:config("experimental") and "ON" or "OFF"))

        local cxflags = {}
        if package:is_plat("windows") then
            cxflags = table.wrap(package:config("cxflags"))
            table.insert(cxflags, "/utf-8")
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})

        if package:config("c_api") then
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                set_languages("c++17")
                target("ZXing-c")
                    set_kind("$(kind)")
                    add_files("wrappers/c/zxing-c.cpp")
                    add_headerfiles("wrappers/c/zxing-c.h", {prefixdir = "ZXing"})
                    add_includedirs("core/src")
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ZXing/ReadBarcode.h>
            void test() {
                int width, height;
                unsigned char* data;
                auto image = ZXing::ImageView(data, width, height, ZXing::ImageFormat::Lum);
            }
        ]]}, {configs = {languages = "c++17"}}))

        if package:config("c_api") then
            assert(package:has_cfuncs("zxing_ImageView_new", {includes = "ZXing/zxing-c.h"}))
        end
    end)
