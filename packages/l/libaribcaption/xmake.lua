package("libaribcaption")
    set_homepage("https://github.com/xqq/libaribcaption")
    set_description("Portable ARIB STD-B24 Caption Decoder/Renderer")
    set_license("MIT")

    add_urls("https://github.com/xqq/libaribcaption/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xqq/libaribcaption.git")

    add_versions("v1.1.1", "278d03a0a662d00a46178afc64f32535ede2d78c603842b6fd1c55fa9cd44683")

    add_deps("cmake")

    add_links("fontconfig", "freetype", "aribcaption", "expat")

    add_configs("exceptions",       {description = "Enable C++ Exceptions", default = true, type = "boolean"})
    add_configs("rtti",             {description = "Enable C++ RTTI", default = true, type = "boolean"})
    add_configs("renderer",         {description = "Enable renderer", default = true, type = "boolean"})

    if is_plat("windows") then
        add_configs("directwrite",  {description = "Enable DirectWrite text rendering backend", default = true, type = "boolean"})
        add_configs("gdi",          {description = "Enable Win32 GDI font provider", default = false, type = "boolean"})
    end

    add_configs("fontconfig",       {description = "Enable Fontconfig font provider", default = is_plat("linux"), type = "boolean"})
    add_configs("freetype",         {description = "Enable FreeType text rendering backend", default = is_plat("android", "linux", "cross", "bsd", "mingw"), type = "boolean"})

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "CoreGraphics", "CoreText")
    end

    on_load(function (package)
        if package:config("renderer") then
            if package:is_plat("windows") then
                if package:config("directwrite") then
                    package:add("syslinks", "ole32", "d2d1", "dwrite", "windowscodecs")
                end
                if package:config("gdi") then
                    package:add("syslinks", "gdi32")
                end
            end
            if package:config("fontconfig") then
                package:add("deps", "fontconfig")
            end
            if package:config("freetype") then
                package:add("deps", "freetype")
            end
        end
    end)

    on_install("windows", "linux", "cross", "bsd", "mingw", "macosx", "iphoneos", "android", function (package)
        local configs = {"-DARIBCC_BUILD_TESTS=OFF", "-DARIBCC_USE_EMBEDDED_FREETYPE=OFF"}
        if package:is_plat("windows") then
            table.insert(configs, "-DARIBCC_USE_DIRECTWRITE=" .. (package:config("directwrite") and "ON" or "OFF"))
            table.insert(configs, "-DARIBCC_USE_GDI_FONT=" .. (package:config("gdi") and "ON" or "OFF"))
        end
        table.insert(configs, "-DARIBCC_USE_FONTCONFIG=" .. (package:config("fontconfig") and "ON" or "OFF"))
        table.insert(configs, "-DARIBCC_USE_FREETYPE=" .. (package:config("freetype") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DARIBCC_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DARIBCC_NO_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))
        table.insert(configs, "-DARIBCC_NO_RTTI=" .. (package:config("rtti") and "OFF" or "ON"))
        table.insert(configs, "-DARIBCC_NO_RENDERER=" .. (package:config("renderer") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)


    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <aribcaption/aribcaption.hpp>
            void test() {
                aribcaption::Context * ctx = new aribcaption::Context();
                aribcaption::Decoder * decoder = new aribcaption::Decoder(*ctx);
                bool init = decoder->Initialize();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
