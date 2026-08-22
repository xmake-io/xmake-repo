package("anari")
    set_homepage("https://github.com/KhronosGroup/ANARI-SDK")
    set_description("ANARI Software Development Kit (SDK)")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/ANARI-SDK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/ANARI-SDK.git")

    add_versions("v0.16.0", "657d995e834ec534b9ac8b57b01f16912320a015fe07ff0ef687e2f3611966b9")
    add_versions("v0.15.0", "8fe0fa1a7eea6768fe69a46313ba405b62b2667b1bae5e843bc751a90a53fad3")
    add_versions("v0.14.1", "a1df9e917bdb0b6edb0ad4b8e59e1171468a446f850559c74ad5731317201e16")
    add_versions("v0.13.1", "b8979ab0dea22cf71c2eacf9421b0cf3fe5807224147c63686d6ed07e65873f4")
    add_versions("v0.12.1", "1fc5cf360b260cc2e652bff4a41dcf3507c84d25701dc6c6630f6f6f83656b6c")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "python 3.x", {kind = "binary"})

    on_install(function (package)
        if not package:config("shared") and package:is_plat("windows", "mingw") then
            package:add("defines", "ANARI_STATIC_DEFINE")
        end

        if package:config("shared") then
            package:add("links", "anari_test_scenes", "anari_library_debug", "anari_library_sink", "helium", "anari", "anari_backend")
        else
            package:add("links", "anari_test_scenes", "helium", "anari_static", "anari_backend")
        end

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_VIEWER=OFF",
            "-DCTS_ENABLE_GLTF=OFF",
            "-DBUILD_HELIDE_DEVICE=OFF",
        }
        if not package:config("shared") then
            table.insert(configs, "-DBUILD_DEBUG_DEVICE=OFF")
            table.insert(configs, "-DBUILD_SINK_DEVICE=OFF")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*anari_static*"))
        else
            os.tryrm(path.join(package:installdir("lib"), "libanari.so*"))
            os.tryrm(path.join(package:installdir("lib"), "libanari*.dylib"))
            os.tryrm(path.join(package:installdir("lib"), "anari.lib"))
            os.tryrm(path.join(package:installdir("bin"), "anari.dll"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("anariLoadLibrary", {includes = "anari/anari.h"}))
    end)
