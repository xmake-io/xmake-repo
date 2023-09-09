import("core.project.project")

--- add arch-specific files
---@param arch string
---@param exts table<string,table>
---@param prefix string
function add_arch_files(target, arch, exts, prefix)
    for _, ext in ipairs(exts) do
        for _, file in ipairs(table.join(os.files(path.join(prefix, arch, "**_" .. ext .. ".c")),
            os.files(path.join(prefix, arch, "generic", "*.c")),
            os.files(path.join(prefix, arch, "**_" .. ext .. ".asm")))) do
            target:add("files", file)
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

--- generate x86inc.asm
---@param path string
function generate_x86inc_asm(path)
    printf("generating " .. path .. " ... ")
    local file = io.open(path, "w")
    for name, opt in pairs(project.options()) do
        if name:startswith("ext-") then
            file:write(
                "%define HAVE_" .. name:sub(5):upper():gsub("%.", "_") .. " " .. (opt:enabled() and "1" or "0") .. "\n")
        else
            file:write("%define CONFIG_" .. name:upper():gsub("%-", "_") .. " " .. (opt:enabled() and "1" or "0") ..
                           "\n")
        end
    end
    file:close()
    cprint("${green bright}ok${clear}")
end
