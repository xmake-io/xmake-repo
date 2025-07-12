package("kittymemory")
    set_homepage("https://github.com/MJx0/KittyMemory")
    set_description("This library aims for runtime code patching for both Android and iOS")
    set_license("MIT")

    add_urls("https://github.com/MJx0/KittyMemory.git", {submodules = false})
    add_versions("2025.05.30", "d0a701c24ecd8b0a4644633e998ac4aa33df7bcd")

    add_configs("keystone", {description = "Use Keystone and MemoryPatch::createWithAsm", default = true, type = "boolean"})
    add_configs("logd", {description = "Define kITTYMEMORY_DEBUG in cpp flags for KITTY_LOGD debug outputs", default = false, type = "boolean"})

    on_load(function (package)
        if not package:config("keystone") then
            package:add("defines", "kNO_KEYSTONE")
        else
            package:add("deps", "keystone")
        end
        if package:config("logd") then
            package:add("defines", "kITTYMEMORY_DEBUG")
        end
    end)

    on_install("android", "iphoneos", function (package)
        io.replace("KittyMemory/KittyUtils.hpp", [[#ifdef __ANDROID__]], [[#ifdef __ANDROID__
#include <sys/system_properties.h>]], {plain = true})
        local configs = {
            keystone = package:config("keystone"),
            logd = package:config("logd")
        }
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")

            option("keystone", {default = true})
            option("logd", {default = false})

            if has_config("keystone") then
                add_requires("keystone")
            end

            target("KittyMemory")
                set_languages("c++11")
                set_kind("$(kind)")
                add_files("KittyMemory/*.cpp")
                add_includedirs("KittyMemory")
                add_headerfiles("(KittyMemory/*.hpp)")
                add_syslinks("log")
                if not has_config("keystone") then
                    add_defines("kNO_KEYSTONE")
                else
                    add_packages("keystone")
                end
                if has_config("logd") then
                    add_defines("kITTYMEMORY_DEBUG")
                end
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs([[KittyMemory::memRead(0, 0, 10)]], {includes = "KittyMemory/KittyMemory.hpp"}))
    end)
