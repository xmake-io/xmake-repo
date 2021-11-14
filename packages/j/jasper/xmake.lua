package("jasper")

    set_homepage("https://www.ece.uvic.ca/~frodo/jasper/")
    set_description("Official Repository for the JasPer Image Coding Toolkit")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jasper-software/jasper/archive/refs/tags/version-$(version).tar.gz")
    add_versions("2.0.28", "6b4e5f682be0ab1a5acb0eeb6bf41d6ce17a658bb8e2dbda95de40100939cc88")
    add_versions("2.0.32", "a3583a06698a6d6106f2fc413aa42d65d86bedf9a988d60e5cfa38bf72bc64b9")
    add_versions("2.0.33", "38b8f74565ee9e7fec44657e69adb5c9b2a966ca5947ced5717cde18a7d2eca6")

    add_configs("opengl", {description = "Enable the use of the OpenGL/GLUT Library.", default = false, type = "boolean"})

    add_deps("cmake", "libjpeg-turbo")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("opengl") then
            package:add("deps", "freeglut")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("build/cmake/modules/JasOpenGL.cmake", "find_package(GLUT", "find_package(FreeGLUT", {plain = true})
        local configs = {"-DJAS_ENABLE_PROGRAMS=OFF", "-DJAS_ENABLE_DOC=OFF"}
        local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
        if vs_sdkver then
            local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
            assert(tonumber(build_ver) >= 18362, "Jasper requires Windows SDK to be at least 10.0.18362.0")
            table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
            table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DJAS_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DJAS_ENABLE_OPENGL=" .. (package:config("opengl") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end

        -- warning: only works on windows sdk 10.0.18362.0 and later
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("jas_image_decode", {includes = "jasper/jasper.h"}))
    end)
