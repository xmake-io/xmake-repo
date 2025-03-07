add_rules("mode.debug", "mode.release")

add_requires("lua 5.4.x", "stb", "sokol", "sokol-tools")

rule("autogen")
    set_extensions(".lua", ".glsl", ".dl")
    on_load(function (target)
        local headerdir = path.join(target:autogendir(), "include")
        if not os.isdir(headerdir) then
            os.mkdir(headerdir)
        end
        target:add("includedirs", headerdir)
    end)
    before_buildcmd_file(function(target, batchcmds, sourcefile, opt)
        local headerdir = path.join(target:autogendir(), "include")
        local headerfile = path.join(headerdir, path.filename(sourcefile) .. ".h")
        local extension = path.extension(sourcefile)
        batchcmds:show_progress(opt.progress, "${color.build.object}generating%s %s", extension, sourcefile)
        if extension == ".lua" then
            batchcmds:vrunv("lua", {"script/lua2c.lua", sourcefile, path.unix(headerfile)})
        elseif extension == ".dl" then
            batchcmds:vrunv("lua", {"script/datalist2c.lua", sourcefile, path.unix(headerfile)})
        elseif extension == ".glsl" then
            batchcmds:vrunv("sokol-shdc", {"--input", sourcefile, "--output", headerfile,
                "--slang", "hlsl4", "--format", "sokol"})
        end
        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(headerfile))
        batchcmds:set_depcache(target:dependfile(headerfile))
    end)

target("soluna")
    set_kind("binary")

    add_files("src/*.c")
    add_files("3rd/datalist/datalist.c")
    add_files("3rd/ltask/src/*.c")

    add_rules("autogen")
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


