import("core.project.project")

local _full_archs = {"aarch64", "arm", "loongarch", "mips", "ppc", "x86", "x86_64"}

function _generate_defines(target, fullarch)
    local defines = {}
    for _, archname in ipairs(_full_archs) do
        defines["VPX_ARCH_" .. archname:upper()] = fullarch == archname
    end

    defines["HAVE_MIPS32"] = target:is_arch("mips32.*")
    defines["HAVE_MIPS64"] = target:is_arch("mips64.*")
    defines["HAVE_HAVE_VPX_PORTS"] = true
    defines["HAVE_PTHREAD_H"] = target:has_cincludes("pthread.h")
    defines["HAVE_UNISTD_H"] = target:has_cincludes("unistd.h")

    for name, opt in pairs(project.options()) do
        if name:startswith("ext-") then
            defines["HAVE_" .. name:sub(5):upper():gsub("%.", "_")] = opt:enabled()
        else
            defines["CONFIG_" .. name:upper():gsub("%-", "_")] = opt:enabled()
        end
    end

    defines["CONFIG_OS_SUPPORT"] = true
    defines["CONFIG_RATE_CTRL"] = false

    return defines
end

--- add arch-specific files
---@param arch string
---@param exts table<string,table>
---@param prefix string
function add_arch_files(target, prefix, arch, fullarch, all_exts)
    local exts = {}
    local rtcd = project.option("runtime-cpu-detect"):enabled()
    for _, ext in ipairs(all_exts[arch]) do
        local opt = project.option("ext-" .. ext.name)
        if opt:value() == "detect" and rtcd or opt:value() == true then
            table.insert(exts, ext.name)
        end
    end
    for _, ext in ipairs(exts) do
        for _, file in ipairs(table.join(os.files(path.join(prefix, arch, "**_" .. ext .. ".*")),
            os.files(path.join(prefix, arch, "**_" .. arch .. ".*")),
            os.files(path.join(prefix, arch, "**_" .. fullarch .. ".*")), os.files(path.join(prefix, "generic", "*")))) do
            if path.extension(file) ~= ".h" then
                target:add("files", file)
            end
        end
    end
end

--- generate msvc export def
---@param name string
---@param path string
function generate_dll_def(name, path)
    printf("generating " .. path .. " ... ")
    local files_mapping = {
        encoders = "vpx/exports_enc",
        decoders = "vpx/exports_dec",
        ["vp8-encoder"] = "vp8/exports_enc",
        ["vp8_decoder"] = "vp8/exports_enc",
        ["vp9-encoder"] = "vp9/exports_enc",
        ["vp9-decoder"] = "vp9/exports_enc"
    }
    local files = {"vpx/exports_com"}
    for optname, filename in pairs(files_mapping) do
        local opt = project.option(optname)
        if opt and opt:enabled() then
            table.insert(files, filename)
        end
    end
    local file = io.open(path, "w")
    file:write("LIBRARY " .. name .. "\nEXPORTS\n")
    for _, filename in ipairs(files) do
        for line in io.lines(filename) do
            local type, funcname = table.unpack(line:split(" ", {
                limit = 2
            }))
            if type == "text" then
                file:write("  " .. funcname .. "\n")
            elseif type == "data" then
                file:write("  " .. funcname .. " DATA\n")
            end
        end
    end
    file:close()
    cprint("${green bright}ok${clear}")
end

--- generate vpx_config.h
---@param path string
---@param target table
---@param fullarch string
function generate_vpx_config_h(path, target, fullarch)
    printf("generating " .. path .. " ... ")
    local file = io.open(path, "w")
    file:write([[#ifndef VPX_CONFIG_H
#define VPX_CONFIG_H
]])

    file:write("#define RESTRICT " ..
                   (target:check_csnippets("int i = 114514; int *restrict a = &i;") and "restrict" or "") .. "\n")
    file:write(
        "#define INLINE " .. (target:check_csnippets("static inline int function(void) {}") and "inline" or "") .. "\n")

    for name, value in pairs(_generate_defines(target, fullarch)) do
        file:write("#define " .. name .. " " .. (value and "1" or "0") .. "\n")
    end

    file:write([[#endif /* VPX_CONFIG_H */
    ]])
    file:close()
    cprint("${green bright}ok${clear}")
end

--- generate vpx_config.asm
---@param path string
---@param target table
---@param fullarch string
function generate_vpx_config_asm(path, target, fullarch)
    printf("generating " .. path .. " ... ")
    local file = io.open(path, "w")
    for name, value in pairs(_generate_defines(target, fullarch)) do
        file:write(name .. " equ " .. (value and "1" or "0") .. "\n")
    end
    file:close()
    cprint("${green bright}ok${clear}")
end
