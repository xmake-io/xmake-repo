package("openal-soft")

    set_homepage("https://openal-soft.org")
    set_description("OpenAL Soft is a software implementation of the OpenAL 3D audio API.")
    set_license("LGPL-2.0")

    add_urls("https://github.com/kcat/openal-soft/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:ge("1.21.0") and version or "openal-soft-" .. version
    end})
    add_urls("https://github.com/kcat/openal-soft.git")

    add_versions("1.21.1", "8ac17e4e3b32c1af3d5508acfffb838640669b4274606b7892aa796ca9d7467f")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::openal")
    elseif is_host("linux") then
        add_extsources("pacman::openal", "apt::libopenal-dev")
    elseif is_host("macosx") then
        add_extsources("brew::openal-soft")
    end
    
    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("ole32", "shell32", "user32", "winmm")
    elseif is_plat("linux", "cross") then
        add_syslinks("dl", "pthread")
    elseif is_plat("android") then
        add_syslinks("dl", "OpenSLES")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreAudio", "CoreFoundation", "AudioToolbox")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "AL_LIBTYPE_STATIC")
        end
    end)

    on_install("windows", "linux", "mingw@linux,msys,windows", "macosx", "android", "iphoneos", "cross", function (package)
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
