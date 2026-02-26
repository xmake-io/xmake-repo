package("rmlui")
    set_homepage("https://mikke89.github.io/RmlUiDoc/")
    set_description("RmlUi is the C++ user interface library based on the HTML and CSS standards.")
    set_license("MIT")

    add_urls("https://github.com/mikke89/RmlUi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mikke89/RmlUi.git")

    add_versions("6.2", "814c3ff7b9666280338d8f0dda85979f5daf028d01c85fc8975431d1e2fd8e8b")
    add_versions("6.1", "b6088bf31858d31bfe657caecf49fd12d5a34f9a37fa1c3061757410c4eb0089")
    add_versions("6.0", "aba3d4b8691076750eee6bf52d722db7880dfe74c18aebd8c6d676e43175fb78")
    add_versions("5.1", "0d28177118f0777e42864b2b7ddfc2937e81eb0dc4c52fc034c71a0c93516626")
    add_versions("5.0", "1f6eac0e140c35275df32088579fc3a0087fa523082c21c28d5066bd6d18882a")

    add_configs("freetype", {description = "Building with the default FreeType font engine.", default = true, type = "boolean"})
    add_configs("lua",      {description = "Build Lua bindings.", default = false, type = "boolean"})
    add_configs("rtti",     {description = "Build with rtti and exceptions enabled.", default = true, type = "boolean"})
    add_configs("svg",      {description = "Build with SVG plugin enabled.", default = false, type = "boolean"})
    add_configs("lottie",   {description = "Build with Lottie plugin enabled.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("shlwapi", "imm32", "user32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa")
    end

    add_deps("cmake")

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
        if package:is_plat("linux") then
            io.replace("Include/RmlUi/Core/Types.h", "#include <cstdlib>", "#include <cstdlib>\n#include <cstdint>\n", {plain = true})
        end

        if package:version() and package:version():eq("6.1") then
            io.replace("Include/RmlUi/Core/Containers/robin_hood.h", "#include <algorithm>", [[
            #include <algorithm>
            #include <cstdint>
            ]], {plain = true})
        end
        
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
