option("cuda", {default = false})
option("dx11", {default = false})
option("dx12", {default = false})
option("opengl", {default = false})
option("metal", {default = false})

add_rules("mode.release", "mode.debug")

target("remotery")
    set_kind("$(kind)")
    add_files("lib/Remotery.c")
    if is_plat("macosx", "iphoneos") then
        add_files("lib/Remotery.mm")
    end
    add_headerfiles("lib/Remotery.h")

    if has_config("cuda") then
        add_defines("RMT_USE_CUDA=1")
    end
    if has_config("dx11") then
        add_defines("RMT_USE_D3D11=1")
    end
    if has_config("dx12") then
        add_defines("RMT_USE_D3D12=1")
    end
    if has_config("opengl") then
        add_defines("RMT_USE_OPENGL=1")
    end
    if has_config("metal") then
        add_defines("RMT_USE_METAL=1")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "winmm")
        if is_plat("windows") and is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end
    elseif is_plat("linux") then
        add_syslinks("pthread", "m")
    end
