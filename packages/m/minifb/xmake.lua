package("minifb")
    set_homepage("https://github.com/emoon/minifb")
    set_description("MiniFB is a small cross platform library to create a frame buffer that you can draw pixels in")
    set_license("MIT")

    add_urls("https://github.com/emoon/minifb.git")
    add_versions("2023.09.21", "2ce2449b1bc8d7c6d20c31b86244f1e540f2e788")

    add_deps("cmake")

    if is_plat("macosx") then
        add_frameworks("Cocoa", "QuartzCore", "Metal", "MetalKit")
    elseif is_plat("iphoneos") then
        add_frameworks("UIKit", "QuartzCore", "Metal", "MetalKit")
    elseif is_plat("linux", "bsd") then
        add_deps("libx11", "libxkbcommon")
        add_deps("glx", "opengl", {optional = true})
    elseif is_plat("windows", "mingw") then
        add_syslinks("gdi32", "opengl32", "user32", "winmm")
    end

    if on_check then
        on_check("windows|arm64", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(minifb) require vs_toolset >= 14.3")
            end
        end)
    end

    on_install("!android and !cross and !bsd", function (package)
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "add_definitions(-D_DEBUG)", "", {plain = true}) -- fix M[D|T]d
        end
        io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("CMakeLists.txt", 'set(CMAKE_C_FLAGS "")', "", {plain = true})
        io.replace("CMakeLists.txt", 'set(CMAKE_CXX_FLAGS "")', "", {plain = true})

        local configs = {"-DMINIFB_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        local opt = {}
        if package:is_plat("linux", "bsd") then
            opt.packagedeps = {"libx11", "libxkbcommon", "glx", "opengl"}
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "minifb.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mfb_update_ex", {includes = "MiniFB.h"}))
    end)
