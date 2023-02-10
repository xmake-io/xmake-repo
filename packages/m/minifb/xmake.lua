package("minifb")
    set_homepage("https://github.com/emoon/minifb")
    set_description("MiniFB is a small cross platform library to create a frame buffer that you can draw pixels in")
    set_license("MIT")

    add_urls("https://github.com/emoon/minifb.git")
    add_versions("2022.11.12", "5312cb7ca07115c918148131d296864b8d67e2d7")

    add_deps("cmake")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    if is_plat("windows") then
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Foundation", "AppKit", "MetalKit", "Metal")
    elseif is_plat("linux") then
        add_deps("libx11", "libxkbcommon")
        add_deps("glx", "opengl", {optional = true})
    elseif is_plat("windows") then
        add_syslinks("gdi32", "opengl32", "user32", "winmm")
    end

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DMINIFB_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local packagedeps
        if package:is_plat("linux") then
            packagedeps = {"libx11", "libxkbcommon", "glx", "opengl"}
            io.replace("CMakeLists.txt", 'set(CMAKE_C_FLAGS "")', "", {plain = true})
            io.replace("CMakeLists.txt", 'set(CMAKE_CXX_FLAGS "")', "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build", packagedeps = packagedeps})
        os.cp("include", package:installdir())
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.lib", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mfb_update_ex", {includes = "MiniFB.h"}))
    end)
