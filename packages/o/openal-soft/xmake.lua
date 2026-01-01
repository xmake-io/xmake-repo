package("openal-soft")

    set_homepage("https://openal-soft.org")
    set_description("OpenAL Soft is a software implementation of the OpenAL 3D audio API.")
    set_license("LGPL-2.0")

    add_urls("https://github.com/kcat/openal-soft/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:ge("1.21.0") and version or "openal-soft-" .. version
    end})
    add_urls("https://github.com/kcat/openal-soft.git")

    add_versions("1.25.0", "c07424e16cc53632a58f7ccaf7f4cd1cf2efde7fe4d2cdca1edbf618ea9470d1")
    add_versions("1.24.3", "7e1fecdeb45e7f78722b776c5cf30bd33934b961d7fd2a11e0494e064cc631ce")
    add_versions("1.23.1", "dfddf3a1f61059853c625b7bb03de8433b455f2f79f89548cbcbd5edca3d4a4a")
    add_versions("1.22.2", "3e58f3d4458f5ee850039b1a6b4dac2343b3a5985a6a2e7ae2d143369c5b8135")
    add_versions("1.22.0", "814831a8013d7365dfd1917b27f1fb6e723f3be3fe1c6a7ff4516425d8392f68")
    add_versions("1.21.1", "8ac17e4e3b32c1af3d5508acfffb838640669b4274606b7892aa796ca9d7467f")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::openal")
    elseif is_plat("linux") then
        add_extsources("pacman::openal", "apt::libopenal-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::openal-soft")
    end

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("libsndio")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ole32", "shell32", "user32", "winmm", "kernel32", "Avrt")
        if is_plat("mingw") then
            add_syslinks("uuid")
        end
    elseif is_plat("linux", "cross") then
        add_syslinks("dl", "pthread")
     elseif is_plat("bsd") then
        add_syslinks("stdthreads", "pthread")
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

    on_install("windows", "linux", "mingw", "macosx", "android", "iphoneos", "cross", "bsd" , function (package)
        -- https://github.com/kcat/openal-soft/issues/864
        io.replace("CMakeLists.txt", "if(HAVE_GCC_PROTECTED_VISIBILITY)", "if(0)", { plain = true })
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
