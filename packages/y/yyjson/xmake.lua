package("yyjson")
    set_homepage("https://github.com/ibireme/yyjson")
    set_description("The fastest JSON library in C.")
    set_license("MIT")

    add_urls("https://github.com/ibireme/yyjson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ibireme/yyjson.git")

    add_versions("0.12.0", "b16246f617b2a136c78d73e5e2647c6f1de1313e46678062985bdcf1f40bb75d")
    add_versions("0.11.1", "610a38a5e59192063f5f581ce0c3c1869971c458ea11b58dfe00d1c8269e255d")
    add_versions("0.10.0", "0d901cb2c45c5586e3f3a4245e58c2252d6b24bf4b402723f6179523d389b165")
    add_versions("0.9.0", "59902bea55585d870fd7681eabe6091fbfd1a8776d1950f859d2dbbd510c74bd")
    add_versions("0.8.0", "b2e39ac4c65f9050820c6779e6f7dd3c0d3fed9c6667f91caec0badbedce00f3")
    add_versions("0.5.1", "b484d40b4e20cc3174a6fdc160d0f20f961417f9cb3f6dc1cf6555fffa8359f3")
    add_versions("0.5.0", "1a65c41d25394c979ad26554a0befb8006ecbf9f7f3a5b0130fdae4f2dd03d42")
    add_versions("0.4.0", "061fe713391d7f3f85f13e8bb2752a4cdeb8e70ce20d68e1e9e4332bd0bf64fa")
    add_versions("0.3.0", "f5ad3e3be40f0307a732c2b8aff9a1ba6014a6b346f3ec0b128459607748e990")    
    add_versions("0.2.0", "43aacdc6bc3876dc1322200c74031b56d8d7838c04e46ca8a8e52e37ea6128da")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "YYJSON_IMPORTS")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                target("yyjson")
                    set_kind("$(kind)")
                    add_files("src/*.c")
                    add_headerfiles("src/*.h")
                    if is_kind("shared") and is_plat("windows") then
                        add_defines("YYJSON_EXPORTS")
                    end
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("yyjson_read", {includes = "yyjson.h"}))
    end)
