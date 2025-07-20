package("libyuv")
    set_homepage("https://chromium.googlesource.com/libyuv/libyuv/")
    set_description("libyuv is an open source project that includes YUV scaling and conversion functionality.")
    set_license("BSD-3-Clause")

    add_urls("https://chromium.googlesource.com/libyuv/libyuv.git",
             "https://github.com/lemenkov/libyuv.git", {alias = "git"})

    -- Versions from LIBYUV_VERSION definition in include/libyuv/version.h
    -- Pay attention to package commits incrementing this definition
    add_versions("git:1913", "6f729fbe658a40dfd993fa8b22bd612bb17cde5c")
    add_versions("git:1891", "611806a1559b92c97961f51c78805d8d9d528c08")

    add_patches("1913", "patches/1913/cmake.patch", "9b61c6a5c26e727d164f06e83a3bf19863f840cd57fcee365429561e640930bf")
    add_patches("1891", "patches/1891/cmake.patch", "87086566b2180f65ff3d5ef9db7c59a6e51e2592aeeb787e45305beb4cf9d30d")

    add_configs("jpeg", {description = "Build with JPEG.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(libyuv): need ndk version > 22")
        end)
    end

    on_load(function (package)
        if package:config("jpeg") then
            package:add("deps", "libjpeg")
        end

        if package:config("shared") then
            package:add("defines", "LIBYUV_USING_SHARED_LIBRARY")
        end
    end)

    on_install("!cross", function (package)
        if package:is_plat("iphoneos") then
            local patch = [[set(arch_lowercase "]] .. package:arch() .. [[")]]
            io.replace("CMakeLists.txt", [[STRING(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" arch_lowercase)]], patch, {plain = true})
            io.replace("CMakeLists.txt", [[string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" arch_lowercase)]], patch, {plain = true})
        end
        -- fix linux arm64 build error
        -- -- commit 1724c4be72f32d2f04eead939f7b3f35ad4e39e3
        -- io.replace("CMakeLists.txt", "-march=armv9-a+sme", "-march=armv9-a+i8mm+sme", {plain = true})
        io.replace("CMakeLists.txt", "-march=armv9-a+sme", "", {plain = true})
        io.replace("CMakeLists.txt", "-march=armv9-a+i8mm+sme", "", {plain = true})

        local configs = {"-DCMAKE_CXX_STANDARD=14"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBYUV_WITH_JPEG=" .. (package:config("jpeg") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("I420Rotate", {includes = "libyuv/rotate.h"}))
    end)
