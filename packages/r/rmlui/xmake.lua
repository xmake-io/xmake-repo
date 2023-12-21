package("rmlui")

    set_homepage("https://mikke89.github.io/RmlUiDoc/")
    set_description("RmlUi is the C++ user interface library based on the HTML and CSS standards.")
    set_license("MIT")

    add_urls("https://github.com/mikke89/RmlUi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mikke89/RmlUi.git")
    add_versions("5.0", "1f6eac0e140c35275df32088579fc3a0087fa523082c21c28d5066bd6d18882a")

    add_configs("freetype", {description = "Building with the default FreeType font engine.", default = true, type = "boolean"})
    add_configs("lua",      {description = "Build Lua bindings.", default = false, type = "boolean"})
    add_configs("rtti",     {description = "Build with rtti and exceptions enabled.", default = true, type = "boolean"})
    add_configs("svg",      {description = "Build with SVG plugin enabled.", default = false, type = "boolean"})
    add_configs("lottie",   {description = "Build with Lottie plugin enabled.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("shlwapi", "imm32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa")
    end
    on_load("windows", "macosx", "linux", function (package)
        if not package:config("shared") then
            package:add("defines", "RMLUI_STATIC_LIB")
        end
        if package:config("freetype") then
            package:add("deps", "freetype", "zlib")
        end
        if package:config("lua") then
            package:add("deps", "lua")
        end
        if package:config("svg") then
            package:add("deps", "lunasvg")
        end
        if package:config("lottie") then
            package:add("deps", "rlottie")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_SAMPLES=OFF"}
        if package:is_plat("macosx") and package:is_arch("arm64") then
            table.insert(configs, "-DCMAKE_OSX_ARCHITECTURES=arm64")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNO_FONT_INTERFACE_DEFAULT=" .. (package:config("freetype") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_LUA_BINDINGS=" .. (package:config("lua") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SVG_PLUGIN=" .. (package:config("svg") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_LOTTIE_PLUGIN=" .. (package:config("lottie") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_RTTI_AND_EXCEPTIONS=" .. (package:config("rtti") and "OFF" or "ON"))
        if package:config("freetype") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"zlib"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <RmlUi/Core.h>
            void test() {
                Rml::Context* context = Rml::CreateContext("default", Rml::Vector2i(640, 480));
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
