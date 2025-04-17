package("csfml")
    set_homepage("https://www.sfml-dev.org")
    set_description("Official binding of SFML for C")
    set_license("zlib")

    add_urls("https://github.com/SFML/CSFML/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SFML/CSFML.git")

    add_versions("2.6.1", "f3f3980f6b5cad85b40e3130c10a2ffaaa9e36de5f756afd4aacaed98a7a9b7b")

    add_configs("graphics",   {description = "Use the graphics module", default = true, type = "boolean"})
    add_configs("window",     {description = "Use the window module", default = true, type = "boolean"})
    add_configs("audio",      {description = "Use the audio module", default = true, type = "boolean"})
    add_configs("network",    {description = "Use the network module", default = true, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("avrt")
    end

    on_load(function (package)
        if package:version():ge("2.6.0") and package:version():le("2.6.1") then
            package:add("deps", "sfml 2.6.1", {configs = {
                graphics = package:config("graphics"),
                window = package:config("window"),
                audio = package:config("audio"),
                network = package:config("network")
            }})
        end
        if package:config("graphics") then
            package:add("deps", "zlib")
        end
    end)

    on_install(function (package)
        local configs = {"-DCSFML_BUILD_DOC=OFF", "-DCSFML_BUILD_EXAMPLES=OFF"}

        table.insert(configs, "-DCSFML_BUILD_GRAPHICS=".. (package:config("graphics") and "ON" or "OFF"))
        table.insert(configs, "-DCSFML_BUILD_WINDOW=".. (package:config("window") and "ON" or "OFF"))
        table.insert(configs, "-DCSFML_BUILD_AUDIO=".. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DCSFML_BUILD_NETWORK=".. (package:config("network") and "ON" or "OFF"))
        if package:is_plat("windows", "mingw") then
            if not package:config("shared") then
                io.replace("include/SFML/Config.h",
                    [[#define CSFML_API_IMPORT CSFML_EXTERN_C __declspec(dllimport)]],
                    [[#define CSFML_API_IMPORT CSFML_EXTERN_C __declspec(dllexport)]], {plain = true})
                -- Do not use CMAKE_SHARED_LIBRARY_SUFFIX when building static lib
                io.replace("cmake/Macros.cmake", "if(SFML_OS_WINDOWS)", "if(0)", {plain = true})
            end
            -- Add missing syslink for Windows
            io.replace("src/SFML/Audio/CMakeLists.txt", "DEPENDS sfml-audio)", "DEPENDS sfml-audio avrt)", {plain = true})
        end
        -- Add missing zlib headers
        if package:config("graphics") then
            io.replace("src/SFML/CMakeLists.txt", 
                [[find_package(SFML 2.6 COMPONENTS ${SFML_MODULES} REQUIRED)]],
                [[find_package(SFML 2.6 COMPONENTS ${SFML_MODULES} REQUIRED)
                find_package(ZLIB)]], {plain = true})
            io.replace("src/SFML/Graphics/CMakeLists.txt", 
                "DEPENDS sfml-graphics)", [[DEPENDS sfml-graphics ZLIB::ZLIB)]], {plain = true})
        end
        -- If dependency SFML is static or shared
        local sfml = package:dep("sfml")
        if sfml then
            table.insert(configs, "-DCSFML_LINK_SFML_STATICALLY=" .. (sfml:config("shared") and "OFF" or "ON"))
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sfWindow_create", {includes = "SFML/Window.h"}))
    end)
