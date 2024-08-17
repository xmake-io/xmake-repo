-- Compile bgfx shader files. Substitution for scripts/shader.mk.
--
-- Usage:
--
-- add_rules("@bgfx/shaders")
-- add_files("shader.vert", {type = "vertex", output_dir = "shaders", output_name = "shader.vert.bin", profiles = {glsl = "330"}})

rule("shaders")
    set_extensions(".vert", ".frag", ".comp")
    on_buildcmd_file(function (target, batchcmds, shaderfile, opt)
        import("lib.detect.find_program")
        import("core.base.option")

        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.shaderc %s", shaderfile)

        -- get bgfx shaderc
        local shaderc = find_program("shadercRelease") or find_program("shadercDebug")
        assert(shaderc, "bgfx shaderc not found! please check your bgfx installation.")

        -- determine arguments for shaderc from fileconfig
        local fileconfig = target:fileconfig(shaderfile)

        local output_filename
        if fileconfig and fileconfig.output_name then
            output_filename = fileconfig.output_name
        else
            output_filename = path.filename(shaderfile) .. ".bin"
        end

        local output_dir
        if fileconfig and fileconfig.output_dir then
            output_dir = fileconfig.output_dir
        else
            output_dir = "shaders"
        end

        local vardef_filename
        if fileconfig and fileconfig.vardef then
            vardef_filename = fileconfig.vardef
        else
            vardef_filename = path.join(
                path.directory(shaderfile),
                path.basename(shaderfile) .. ".varying.def.sc")
        end

        local shader_type
        if fileconfig and fileconfig.type then
            if table.contains(bgfx_types, fileconfig.type) then
                shader_type = fileconfig.type
            else
                raise("unsupported shader type " .. fileconfig.type)
            end
        elseif shaderfile:match("%.vert$") then
            shader_type = "vertex"
        elseif shaderfile:match("%.frag$") then
            shader_type = "fragment"
        elseif shaderfile:match("%.comp$") then
            shader_type = "compute"
        else
            raise("cannot determine shader type from file name " .. path.filename(shaderfile))
        end

        -- determine platform-specific shaderc arguments
        local bgfx_platforms = {
            windows = "windows",
            macosx = "osx",
            linux = "linux"
        }
        local bgfx_types = {
            "vertex",
            "fragment",
            "compute"
        }
        local bgfx_default_profiles = {
            windows = {
                vertex = {dx9 = "s_3_0", dx11 = "s_5_0", glsl = "120"},
                fragment = {dx9 = "s_3_0", dx11 = "s_5_0", glsl = "120"},
                compute = {dx11 = "s_5_0", glsl = "430"},
            },
            macosx = {
                vertex = {metal = "metal", glsl = "120"},
                fragment = {metal = "metal", glsl = "120"},
                compute = {metal = "metal", glsl = "430"}
            },
            linux = {
                vertex = {glsl = "120", spirv = "spirv"},
                fragment = {glsl = "120", spirv = "spirv"},
                compute = {glsl = "430", spirv = "spirv"}
            }
        }

        -- build command args
        local args = {
            "-f", shaderfile,
            "--type", shader_type,
            "--varyingdef", vardef_filename,
            "--platform", bgfx_platforms[target:plat()],
        }
        for _, includedir in ipairs(target:get("includedirs")) do
            table.insert(args, "-i")
            table.insert(args, includedir)
        end

        local mtime = 0
        local shader_profiles
        if fileconfig and fileconfig.profiles then
            shader_profiles = fileconfig.profiles
        else
            shader_profiles = bgfx_default_profiles[target:plat()][shader_type]
        end
        for folder, profile in pairs(shader_profiles) do
            -- set output dir
            local outputdir = path.join(target:targetdir(), output_dir, folder)
            batchcmds:mkdir(outputdir)
            local binary = path.join(outputdir, output_filename)
            
            -- compiling
            local real_args = {}
            table.join2(real_args, args)
            table.insert(real_args, "-o")
            table.insert(real_args, binary)
            table.insert(real_args, "--profile")
            table.insert(real_args, profile)
            if option.get("verbose") then
                batchcmds:show(shaderc .. " " ..  os.args(real_args))
            end
            batchcmds:vrunv(shaderc, real_args)

            if (mtime == 0) then mtime = os.mtime(binary) end
        end

        -- add deps
        batchcmds:add_depfiles(shaderfile)
        batchcmds:set_depmtime(mtime)
    end)
