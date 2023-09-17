import("core.project.project")
import("utils")

---@alias Functions table<string,table<string,string|string[]>>

local common_top = [[#ifndef %s
#define %s

#ifdef RTCD_C
#define RTCD_EXTERN
#else
#define RTCD_EXTERN extern
#endif
]]
local common_middle = [[
#ifdef __cplusplus
extern "C" {
#endif
]]
local common_buttom = [[
#ifdef __cplusplus
}  // extern "C"
#endif
    
#endif
]]

local setup = {
    x86 = {
        prefix = [[
#ifdef RTCD_C
#include "vpx_ports/x86.h"
static void setup_rtcd_internal(void)
{
    int flags = x86_simd_caps();

    (void)flags;
]],
        suffix = [[
}
#endif
]]
    },
    arm = {
        prefix = [[
#include "vpx_config.h"

#ifdef RTCD_C
#include "vpx_ports/arm.h"
static void setup_rtcd_internal(void)
{
    int flags = arm_cpu_caps();

    (void)flags;
]],
        suffix = [[
}
#endif
]]
    },
    loongarch = {
        prefix = [[
#include "vpx_config.h"

#ifdef RTCD_C
#include "vpx_ports/loongarch.h"
static void setup_rtcd_internal(void)
{
    int flags = loongarch_cpu_caps();

    (void)flags;
]],
        suffix = [[
}
#endif
]]
    },
    mips = {
        prefix = [[
#include "vpx_config.h"

#ifdef RTCD_C
#include "vpx_ports/mips.h"
static void setup_rtcd_internal(void)
{
    int flags = mips_cpu_caps();
        (void)flags;
]],
        suffix = [[
#if HAVE_DSPR2
void vpx_dsputil_static_init();
#if CONFIG_VP8
void dsputil_static_init();
#endif

vpx_dsputil_static_init();
#if CONFIG_VP8
dsputil_static_init();
#endif
#endif
}
#endif
]]
    },
    ppc = {
        prefix = [[
#include "vpx_config.h"
     
#ifdef RTCD_C
#include "vpx_ports/ppc.h"
static void setup_rtcd_internal(void)
{
    int flags = ppc_simd_caps();
    (void)flags;
]],
        suffix = [[
}
#endif
]]
    }
}

function _check_expr(name, operator)
    local enabled = false
    local opt = project.option(name:lower():gsub("_", "-"))
    if opt then
        enabled = opt:enabled()
    end
    return (operator == "eq" and enabled) or (operator == "ne" and not enabled)
end

function _processIfBlock(str)
    function processor(exprs, ifBody, elseBody)
        exprs = exprs:sub(2, -2):trim()
        local result = false
        local optname, operator = exprs:match('^vpx_config%("CONFIG_([%w_]+)"%) (%a%a) "yes"')
        if optname and operator then
            result = _check_expr(optname, operator)
        end
        for logical_op, optname, relational_op in
            exprs:gmatch('([&|][&|]) vpx_config%("CONFIG_([%w_]+)"%) (%a%a) "yes"') do
            if logical_op == "||" then
                result = result or _check_expr(optname, relational_op)
            else
                result = result and _check_expr(optname, relational_op)
            end
        end

        if result then
            return _processIfBlock(ifBody:sub(2, -2):trim())
        elseif elseBody then
            return _processIfBlock(elseBody:sub(2, -2):trim())
        else
            return ""
        end
    end
    return str:gsub("if (%b())%s+(%b{})%s+else (%b{})", processor):gsub("if (%b())%s+(%b{})", processor)
end

--- read rtcd defines from perl file `path`
---@param path string
---@param fullarch string
---@return table<string,table>, table<string,string>, string
function _read_defs(path, fullarch)
    local functions = {}
    local aliases = {}
    local decls = ""

    local defs = io.readfile(path)

    defs = _processIfBlock(defs)

    -- parse decls
    local declfunc = defs:match("forward_decls qw/([%w_]+)/")
    if declfunc then
        defs:gsub("sub " .. declfunc .. "%(%) {\n%s*print <<EOF\n(.+)EOF\n}", function(_decls)
            decls = _decls
            return ""
        end)
    end

    for _, line in ipairs(defs:split("\n", {
        plain = true
    })) do
        local sharp_pos = line:find("#")
        if sharp_pos ~= nil then
            line = line:sub(1, sharp_pos - 1)
        end
        line = line:trim()
        local rettype, name, params = line:match("^add_proto qw/([%w_%s]+)%s([%w_]+)/,%s\"(.+)\";$")
        if rettype and name and params then
            functions[name] = {
                params = params,
                rettype = rettype,
                vers = {"c"}
            }
        else
            local name, exts, extra_ext = line:match("^specialize qw/([%w_]+)%s?(.*)/,?%s?\"?($?[%w_]*)\"?;$")
            if name and exts then
                if functions[name] then
                    local exts = exts:split("%s")
                    if extra_ext and extra_ext:endswith("_" .. fullarch) then
                        table.insert(exts, extra_ext:sub(1, extra_ext:len() - fullarch:len() - 1))
                    end
                    table.join2(functions[name].vers, exts)
                end
            else
                local src, dest = line:match("^$([%w_]+)=([%w_]+);")
                if src and dest then
                    aliases[src] = dest
                end
            end
        end
    end
    return functions, aliases, decls
end

--- generate and write rtcd header to `output`
---@param output string
---@param arch string
---@param all_exts table<string,table[]>
---@param functions Functions
---@param decls string
---@param aliases table<string,string>
function _write_header(output, arch, all_exts, functions, aliases, decls)
    local rtcd = project.option("runtime-cpu-detect"):enabled()
    local rtcd_content = ""
    ---@type table<string,boolean|string>
    local exts = {
        c = true
    }
    for _, ext in ipairs(all_exts[arch]) do
        local opt = project.option("ext-" .. ext.name)
        if opt:value() == "detect" and rtcd or opt:value() == true then
            exts[ext.name] = opt:value()
        end
    end

    local file = io.open(output, "w")
    local def_name = path.basename(output):upper():gsub("%-", "_")
    file:write(format(common_top, def_name, def_name))
    file:write(decls)
    file:write(common_middle)
    for name, info in pairs(functions) do
        local best
        ---@type string[]
        local rtcd_exts = {}
        for _, extname in ipairs(info.vers) do
            if exts[extname] then
                local funcname = name .. "_" .. extname
                funcname = aliases[funcname] or funcname
                file:write(info.rettype .. " " .. funcname .. "(" .. info.params .. ");\n")
                if exts[extname] == "detect" then
                    table.insert(rtcd_exts, extname)
                else
                    best = funcname
                end
            end
        end

        if rtcd and #rtcd_exts > 0 then
            file:write("RTCD_EXTERN " .. info.rettype .. "(*" .. name .. ")(" .. info.params .. ");\n\n")
            rtcd_content = rtcd_content .. "    " .. name .. " = " .. best .. ";\n"
            for _, extname in ipairs(rtcd_exts) do
                local funcname = name .. "_" .. extname
                funcname = aliases[funcname] or funcname
                rtcd_content = rtcd_content .. "    if (flags & HAS_" .. extname:upper() .. ") " .. name .. " = " ..
                                   funcname .. ";\n"
            end
        else
            file:write("#define " .. name .. " " .. best .. "\n\n")
        end
    end

    file:write(setup[arch].prefix)
    file:write(rtcd_content)
    file:write(setup[arch].suffix)
    file:write(common_buttom)
    file:close()
end

function generate(target, arch, fullarch, exts, input, output)
    printf("generating " .. input .. " ... ")
    input = path.translate(vformat(input))
    output = path.translate(vformat(output))
    local functions, aliases, decls = _read_defs(input, fullarch)

    _write_header(output, arch, exts, functions, aliases, decls)
    cprint("${green bright}ok${clear}")
end
