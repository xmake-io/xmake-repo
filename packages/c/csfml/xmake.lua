package("csfml")
    set_homepage("https://www.sfml-dev.org")
    set_description("Official binding of SFML for C")
    set_license("zlib")

    add_urls("https://github.com/SFML/CSFML/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SFML/CSFML.git")

    add_versions("3.0.0", "903cd4a782fb0b233f732dc5b37861b552998e93ae8f268c40bd4ce50b2e88ca")
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
        if package:version():ge("3.0.0") then
            if not package:config("shared") then
                package:add("defines", "CSFML_STATIC")
            end
            package:add("deps", "sfml " .. package:version(), {configs = {
                graphics = package:config("graphics"),
                window = package:config("window"),
                audio = package:config("audio"),
                network = package:config("network")
            }})
        else
            if package:version():ge("2.6.0") and package:version():le("2.6.1") then
                package:add("deps", "sfml " .. package:version(), {configs = {
                    graphics = package:config("graphics"),
                    window = package:config("window"),
                    audio = package:config("audio"),
                    network = package:config("network")
                }})
            end
        end
        if package:config("graphics") then
            package:add("deps", "zlib")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw@windows,msys", function (package)
        if package:version():lt("3.0.0") then
            -- Mac OS X do not use BUILD_WITH_INSTALL_RPATH 1 INSTALL_NAME_DIR "@rpath"
            io.replace("cmake/Macros.cmake", "if(SFML_OS_MACOSX AND BUILD_SHARED_LIBS)", "if(0)", {plain = true})
            if package:is_plat("windows", "mingw") then
                if not package:config("shared") then
                    if package:is_plat("windows") then
                        io.replace("include/SFML/Config.h",
                            [[#define CSFML_API_IMPORT CSFML_EXTERN_C __declspec(dllimport)]],
                            [[#define CSFML_API_IMPORT CSFML_EXTERN_C __declspec(dllexport)]], {plain = true})
                    end
                    if package:is_plat("mingw") then
                        io.replace("cmake/Macros.cmake", [[if (SFML_OS_WINDOWS AND SFML_COMPILER_GCC)]], [[if(0)]], {plain = true})
                        io.replace("include/SFML/Config.h",
                            [[#define CSFML_API_IMPORT CSFML_EXTERN_C __declspec(dllimport)]],
                            [[#define CSFML_API_IMPORT CSFML_EXTERN_C]], {plain = true})
                    end
                    -- Do not use CMAKE_SHARED_LIBRARY_SUFFIX when building static lib
                    io.replace("cmake/Macros.cmake", "if(SFML_OS_WINDOWS)", "if(0)", {plain = true})
                end
                -- Add missing syslink
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
        end
        local configs = {"-DCSFML_BUILD_EXAMPLES=OFF", "-DCSFML_BUILD_DOC=OFF"}
        table.insert(configs, "-DCSFML_BUILD_GRAPHICS=".. (package:config("graphics") and "ON" or "OFF"))
        table.insert(configs, "-DCSFML_BUILD_WINDOW=".. (package:config("window") and "ON" or "OFF"))
        table.insert(configs, "-DCSFML_BUILD_AUDIO=".. (package:config("audio") and "ON" or "OFF"))
        table.insert(configs, "-DCSFML_BUILD_NETWORK=".. (package:config("network") and "ON" or "OFF"))
        -- If dependency SFML is static or shared
        local sfml = package:dep("sfml")
        if sfml then
            table.insert(configs, "-DSFML_ROOT=" .. sfml:installdir())
            table.insert(configs, "-DCSFML_LINK_SFML_STATICALLY=" .. (sfml:config("shared") and "OFF" or "ON"))
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "zlib"})
    end)

    on_test(function (package)
        local includedir = package:version():ge("3.0.0") and "CSFML" or "SFML"
        if package:config("graphics") then
            assert(package:has_cfuncs("sfImage_create", {includes = includedir .. "/Graphics.h"}))
        end
        if package:config("window") then
            assert(package:has_cfuncs("sfWindow_create", {includes = includedir .. "/Window.h"}))
        end
        if package:config("audio") then
            assert(package:has_cfuncs("sfMusic_createFromMemory", {includes = includedir .. "/Audio.h"}))
        end
        if package:config("network") then
            assert(package:has_cfuncs("sfTcpSocket_create", {includes = includedir .. "/Network.h"}))
        end
    end)
