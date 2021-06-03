package("openal-soft")

    set_homepage("https://github.com/paceholder/nodeeditor")
    set_description("OpenAL Soft is a software implementation of the OpenAL 3D audio API.")
    set_license("LGPL-2.0")

    add_urls("https://github.com/kcat/openal-soft/archive/refs/tags/$(version).tar.gz", {version = function (version)
        if version:ge("1.21.0") then
            if version:startswith("openal-soft-") then
                return version:sub(13)
            else
                return version
            end
        else
            return "openal-soft-" .. version
        end
    end})
    add_urls("https://github.com/kcat/openal-soft.git")

    add_versions("1.21.1", "8ac17e4e3b32c1af3d5508acfffb838640669b4274606b7892aa796ca9d7467f")
    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("ole32", "shell32", "user32", "winmm")
    elseif is_plat("linux", "android")
        add_syslinks("dl", "pthread")
        if is_plat("android") then
            add_syslinks("opensles")
        end
    elseif is_plat("macosx") then
        add_frameworks("CoreAudio", "CoreFoundation", "AudioToolbox")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "AL_LIBTYPE_STATIC")
        end
    end)

    on_install("windows", "linux", "mingw", "macosx", "android", "iphoneos", function (package)
        local configs = {"-DALSOFT_EXAMPLES=OFF", "-DALSOFT_UTILS=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DLIBTYPE=SHARED")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DLIBTYPE=STATIC")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("alGetProcAddress", {includes = "AL/al.h"}))
    end)
