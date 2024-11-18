package("emscripten-glfw")
    set_homepage("https://pongasoft.github.io/emscripten-glfw/test/demo/main.html")
    set_description("This project is an emscripten port of GLFW written in C++ for the web/webassembly platform #wasm")
    set_license("Apache-2.0")

    add_urls("https://github.com/pongasoft/emscripten-glfw.git")
    add_urls("https://github.com/pongasoft/emscripten-glfw/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            return "v3.4.0." .. tostring(version):gsub("%.", "")
        end
    })

    add_versions("2024.09.07", "ad4eea0c52ce61921da18e9fc8b6402a4a2e4515a8c783e2f1ae62671ab23fe3")

    add_configs("joystick", {description = "Enable joystick support", default = true, type = "boolean"})
    add_configs("multi_window", {description = "Enable multi window support", default = true, type = "boolean"})

    add_syslinks("GL")

    add_deps("cmake")

    on_load(function (package)
        if not package:is_debug() then
            package:add("defines", "EMSCRIPTEN_GLFW3_DISABLE_WARNING")
        end
        if not package:config("joystick") then
            package:add("defines", "EMSCRIPTEN_GLFW3_DISABLE_JOYSTICK")
        end
        if not package:config("multi_window") then
            package:add("defines", "EMSCRIPTEN_GLFW3_DISABLE_MULTI_WINDOW_SUPPORT")
        end
    end)

    on_install("wasm", function (package)
        io.replace("CMakeLists.txt", "if(CMAKE_CURRENT_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)",
        [[  include(GNUInstallDirs)
            install(TARGETS ${target}
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            )
            install(DIRECTORY external/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
            install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
            install(FILES src/js/lib_emscripten_glfw3.js DESTINATION ${CMAKE_INSTALL_BINDIR})
        if(0)]], {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DEMSCRIPTEN_GLFW3_DISABLE_JOYSTICK=" .. (package:config("joystick") and "OFF" or "ON"))
        table.insert(configs, "-DEMSCRIPTEN_GLFW3_DISABLE_MULTI_WINDOW_SUPPORT =" .. (package:config("multi_window") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)

        package:add("ldflags",
            "--js-library",
            package:installdir("bin/lib_emscripten_glfw3.js"),
            os.files(package:installdir("lib/*.a"))[1]
        )
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glfwInit", {includes = "GLFW/glfw3.h"}))
        assert(package:has_cfuncs("emscripten_glfw_open_url", {includes = "GLFW/emscripten_glfw3.h"}))
    end)
