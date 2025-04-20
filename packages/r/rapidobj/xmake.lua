package("rapidobj")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/guybrush77/rapidobj")
    set_description("A fast, header-only, C++17 library for parsing Wavefront .obj files.")
    set_license("MIT")

    add_urls("https://github.com/guybrush77/rapidobj/archive/refs/tags/$(version).tar.gz",
             "https://github.com/guybrush77/rapidobj.git")

    add_versions("v1.1", "87640b4d70905081552d31a36e6b68a947e167ba379a7032a056986c16f716d3")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(rapidobj): need ndk api level  > 21 for android")
        end)
    end

    on_install("!wasm and !bsd", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DRAPIDOBJ_BuildTools=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                rapidobj::Result result = rapidobj::ParseFile("/home/user/teapot/teapot.obj");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "rapidobj/rapidobj.hpp"}))
    end)
