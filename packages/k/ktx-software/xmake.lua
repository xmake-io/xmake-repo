package("ktx-software")
    set_homepage("https://github.com/KhronosGroup/KTX-Software")
    set_description("KTX (Khronos Texture) Library and Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/KTX-Software.git")

    add_versions("v4.2.1", "a493bf482ff78404b1a3a242c3cc5002d8b980b164bd2e79195f7b633cee50b4")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DKTX_FEATURE_TESTS=OFF", "-DKTX_WERROR=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DKTX_FEATURE_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            if not package:config("shared") then
                package:add("defines", "KHRONOS_STATIC")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ktxTexture_CreateFromNamedFile", {includes = "ktx.h"}))
    end)
