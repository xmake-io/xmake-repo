package("clip")
    set_homepage("https://github.com/dacap/clip")
    set_description("Library to copy/retrieve content to/from the clipboard/pasteboard.")
    set_license("MIT")

    add_urls("https://github.com/dacap/clip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dacap/clip.git")

    add_versions("v1.13", "0d07f80bc48c16d049778501bfb4a58d4f5c4087fd99a53b0640d64dc3b86868")
    add_versions("v1.12", "54e96e04115c7ca1eeeecf432548db5cd3dddb08a91ededb118adc31b128e08c")
    add_versions("v1.11", "047d43f837adffcb3a26ce09fd321472615cf35a18e86418d789b70d742519dc")

    add_configs("image", {description = "Compile with support to copy/paste images", default = true, type = "boolean"})
    add_configs("list_format", {description = "Compile with support to list clipboard formats", default = false, type = "boolean"})
    add_configs("xp", {description = "Enable Windows XP support", default = false, type = "boolean"})
    add_configs("x11_png", {description = "Compile with libpng to support copy/paste image in png format", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("libxcb")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32", "shlwapi", "ole32", "user32", "windowscodecs", "uuid")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "AppKit", "CoreGraphics")
    end

    on_load(function(package)
        if package:config("image") then
            package:add("defines", "CLIP_ENABLE_IMAGE=1")
        end
        if package:config("list_format") then
            package:add("defines", "CLIP_ENABLE_LIST_FORMATS=1")
        end

        if package:is_plat("linux") and package:config("image") and package:config("x11_png") then
            package:add("deps", "libpng")
        end
    end)

    on_install("!android and !iphoneos and !bsd and !cross", function(package)
        io.replace("CMakeLists.txt", "ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}", "ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}\nRUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}", {plain = true})
        io.replace("CMakeLists.txt", "if(CLIP_WINDOWSCODECS_LIBRARY)", "if(1)", {plain = true})
        io.replace("CMakeLists.txt", "target_link_libraries(clip ${CLIP_WINDOWSCODECS_LIBRARY})", "target_link_libraries(clip windowscodecs)", {plain = true})

        local configs = {"-DCLIP_EXAMPLES=OFF", "-DCLIP_TESTS=OFF", "-DCMAKE_INSTALL_INCLUDEDIR=include/clip"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DCLIP_ENABLE_IMAGE=" .. (package:config("image") and "ON" or "OFF"))
        table.insert(configs, "-DCLIP_ENABLE_LIST_FORMATS=" .. (package:config("list_format") and "ON" or "OFF"))
        table.insert(configs, "-DCLIP_SUPPORT_WINXP=" .. (package:config("xp") and "ON" or "OFF"))
        table.insert(configs, "-DCLIP_X11_WITH_PNG=" .. (package:config("x11_png") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                clip::set_text("foo");
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"clip/clip.h"}}))
    end)
