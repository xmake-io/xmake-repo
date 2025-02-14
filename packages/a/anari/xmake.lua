package("anari")
    set_homepage("https://github.com/KhronosGroup/ANARI-SDK")
    set_description("ANARI Software Development Kit (SDK)")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/ANARI-SDK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/ANARI-SDK.git")

    add_versions("v0.12.1", "1fc5cf360b260cc2e652bff4a41dcf3507c84d25701dc6c6630f6f6f83656b6c")

    add_deps("cmake", "python 3.x", {kind = "binary"})

    on_install(function (package)
        if not package:config("shared") and package:is_plat("windows") then
            package:add("defines", "ANARI_STATIC_DEFINE")
        end

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_VIEWER=OFF",
            "-DCTS_ENABLE_GLTF=OFF",
            "-DBUILD_HELIDE_DEVICE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (not package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("anariLoadLibrary", {includes = "anari/anari.h"}))
    end)
