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
        os.vrunv("lua", {"script/lua2c.lua", sourcefile, headerfile})
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
        os.vrunv("lua", {"script/datalist2c.lua", sourcefile, headerfile})
        target:add("includedirs", headerdir, {public = true})
    end)

target("soluna")
    set_kind("binary")
    add_rules("lua2c", "glsl2c", "datalist2c")
    add_files("src/*.c")
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
    end

