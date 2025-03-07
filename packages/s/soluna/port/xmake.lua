add_rules("mode.debug", "mode.release")

add_requires("lua 5.4.x", "stb", "sokol", "sokol-tools")

rule("lua2c")
    set_extensions(".lua")
    before_build_file(function(target, sourcefile)
        local headerdir = path.join(target:autogendir(), "lua2c", "include")
        if not os.isdir(headerdir) then
            os.mkdir(headerdir)
        end
        local headerfile = path.join(headerdir, path.filename(sourcefile) .. ".h")
        os.vrunv("lua", {"script/lua2c.lua", sourcefile, path.unix(headerfile)})
        target:add("includedirs", headerdir, {public = true})
    end)

rule("glsl2c")
    set_extensions(".glsl")
    before_build_file(function(target, sourcefile)
        local headerdir = path.join(target:autogendir(), "glsl", "include")
        if not os.isdir(headerdir) then
            os.mkdir(headerdir)
        end
        local headerfile = path.join(headerdir, path.filename(sourcefile) .. ".h")
        os.vrunv("sokol-shdc", {"--input", sourcefile, "--output", headerfile,
            "--slang", "hlsl4", "--format", "sokol"})
        target:add("includedirs", headerdir, {public = true})
    end)

rule("datalist2c")
    set_extensions(".dl")
    before_build_file(function(target, sourcefile)
        local headerdir = path.join(target:autogendir(), "datalist2c", "include")
        if not os.isdir(headerdir) then
            os.mkdir(headerdir)
        end
        local headerfile = path.join(headerdir, path.filename(sourcefile) .. ".h")
        os.vrunv("lua", {"script/datalist2c.lua", sourcefile, path.unix(headerfile)})
        target:add("includedirs", headerdir, {public = true})
    end)

target("soluna")
    set_kind("binary")
    add_rules("lua2c", "glsl2c", "datalist2c")

    add_files("src/*.c")
    add_files("3rd/datalist/datalist.c")
    add_files("3rd/ltask/src/*.c")

    add_files("src/*.glsl")
    add_files("src/data/*.dl")
    add_files("3rd/ltask/lualib/*.lua")
    add_files("3rd/ltask/service/*.lua")
    add_files("src/lualib/*.lua")
    add_files("src/service/*.lua")

    add_packages("lua", "stb", "sokol", "sokol-tools")
    if is_plat("macosx") then
       add_defines("SOKOL_METAL")
       add_cflags("-x objective-c", {force = true})
       add_frameworks("QuartzCore", "Foundation", "Metal", "MetalKit", "CoreFoundation", "CoreGraphics", "AppKit")
    elseif is_plat("windows") then
        add_defines("SOKOL_D3D11")
        add_defines("_WIN32_WINNT=0x0601")
        add_syslinks("kernel32", "user32", "shell32", "gdi32", "dxgi", "d3d11", "winmm", "ws2_32", "ntdll")
        add_ldflags("/subsystem:windows")
    end
    add_defines("LTASK_EXTERNAL_OPENLIBS=soluna_openlibs")


