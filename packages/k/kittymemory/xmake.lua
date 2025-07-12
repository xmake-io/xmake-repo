package("kittymemory")
    set_homepage("https://github.com/MJx0/KittyMemory")
    set_description("This library aims for runtime code patching for both Android and iOS")
    set_license("MIT")

    add_urls("https://github.com/MJx0/KittyMemory.git", {submodules = false})
    add_versions("2025.05.30", "d0a701c24ecd8b0a4644633e998ac4aa33df7bcd")

    add_deps("keystone")

    on_install("android", "iphoneos", function (package)
        io.replace("KittyMemory/KittyUtils.hpp", [[#ifdef __ANDROID__]], [[#ifdef __ANDROID__
#include <sys/system_properties.h>]], {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("keystone")
            target("KittyMemory")
                set_languages("c++11")
                set_kind("$(kind)")
                add_files("KittyMemory/*.cpp")
                add_includedirs("KittyMemory")
                add_headerfiles("(KittyMemory/*.hpp)")
                add_packages("keystone")
                add_syslinks("log")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs([[KittyMemory::memRead(0, 0, 10)]], {includes = "KittyMemory/KittyMemory.hpp"}))
    end)
