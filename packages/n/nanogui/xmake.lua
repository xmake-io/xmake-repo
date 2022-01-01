package("nanogui")

    set_homepage("https://github.com/wjakob/nanogui")
    set_description("Minimalistic GUI library for OpenGL")

    add_urls("https://github.com/wjakob/nanogui.git")
    add_versions("2019.9.23", "e9ec8a1a9861cf578d9c6e85a6420080aa715c03")

    add_deps("cmake", "eigen", "glfw", "nanovg")
    if is_plat("linux") then
        add_deps("libxi", "libxcursor", "libxinerama", "libxrandr", "libxxf86vm")
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreGraphics", "CoreVideo", "IOKit", "AppKit")
    elseif is_plat("windows") then
        add_syslinks("comdlg32")
    end

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DNANOGUI_BUILD_EXAMPLE=OFF", "-DNANOGUI_BUILD_PYTHON=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DNANOGUI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", '$<TARGET_OBJECTS:glfw_objects>', "", {plain = true})
        io.replace("CMakeLists.txt", 'ext/nanovg/src/nanovg.c', "", {plain = true})
        io.replace("CMakeLists.txt", 'add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/ext/glfw" "ext_build/glfw")', "", {plain = true})
        io.replace("CMakeLists.txt", 'set_target_properties(glfw PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)', "", {plain = true})
        if package:is_plat("linux", "windows") then
            io.replace("include/nanogui/opengl.h", '#include <nanovg.h>', [[#include <nanovg.h>
#ifdef _MSC_VER
#   include <windows.h>
#   define glUniform1i(...) // FIXME: indentify not found
#endif
#include <GL/gl.h>]], {plain = true})
        end
        os.rm("ext/eigen")
        local packagedeps = {"eigen", "nanovg", "glfw"}
        if package:is_plat("linux") then
            table.join2(packagedeps, "libxi", "libxcursor", "libxinerama", "libxrandr", "libxxf86vm")
            io.replace("CMakeLists.txt", 'target_link_libraries(nanogui ${NANOGUI_EXTRA_LIBS})',
                'target_link_libraries(nanogui ${NANOGUI_EXTRA_LIBS} nanovg)', {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <nanogui/nanogui.h>
            using namespace std;
            using namespace nanogui;
            void test() {
                Button *b = new Button(NULL/*window*/, "Plain button");
                b->setCallback([] { cout << "pushed!" << endl; });
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
