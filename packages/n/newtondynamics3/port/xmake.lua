add_rules("mode.debug", "mode.release")

target("newton")
    set_kind("$(kind)")
    set_languages("c89", "cxx11")
    if is_plat("windows") or is_plat("mingw") then
        add_defines("_WINDOWS", "_CRT_SECURE_NO_WARNINGS")
        if is_arch("x86") then
            add_defines("_WIN_32_VER")
        else
            add_defines("_WIN_64_VER")
        end
        if is_plat("mingw") then
            if is_arch("x86") then
                add_defines("_MINGW_32_VER")
            else
                add_defines("_MINGW_64_VER")
            end
        end
    elseif is_plat("linux", "android") then
        add_syslinks("dl")
        if is_arch("x86") then
            add_defines("_POSIX_VER")
        else
            add_defines("_POSIX_VER_64")
        end
        if is_plat("android") then
            add_defines("_ARM_VER")
            add_cxflags("-mfpu=neon", {force = true})
            add_cxflags("-mfloat-abi=soft", {force = true})
            add_cxflags("-include arm_neon.h", {force = true})
        else
            add_syslinks("pthread")
        end
    elseif is_plat("macosx", "iphoneos") then
        add_defines("_MACOSX_VER")
        if is_plat("iphoneos") then
            add_cxflags("-include emmintrin.h", {force = true})
        end
    end

    if is_plat("windows") then
        if is_kind("static") then
            add_defines("_NEWTON_STATIC_LIB", {public = true})
        else
            add_defines("_NEWTON_BUILD_DLL")
        end
    end

    if is_mode("release") and not is_plat("android") then
        add_vectorexts("sse", "sse2", "sse3")
    end

    add_includedirs("sdk", "sdk/dgCore", "sdk/dgMeshUtil", "sdk/dgPhysics", "sdk/dgNewton")
    add_files("sdk/dgCore/**.cpp")
    add_files("sdk/dgPhysics/**.cpp")
    add_files("sdk/dgMeshUtil/**.cpp")
    add_files("sdk/dgNewton/**.cpp")

    before_install(function (package)
        local targetHeader = path.join(package:installdir(), "include", "newton", "Newton.h")
        os.vcp("sdk/dgNewton/Newton.h", path.join(package:installdir(), "include", "newton", "Newton.h"))
    end)
