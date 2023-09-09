import("core.project.project")

---@alias Archs "x86"|"arm"|"loongarch"|"mips"|"ppc"
---@alias Functions table<Archs,table<string,string|string[]>>

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

---@param target table
---@param exts string[]
---@return string[]
function detect_exts(target, exts)
    local result = {"c"}
    for _, ext in ipairs(exts) do
        local opt = project.option("ext-" .. ext.name)
        if opt then
            if opt:value() == "detect" then
                local enable = true
                if ext.flags then
                    for _, flag in ipairs(ext.flags) do
                        if enable then
                            enable = target:has_cflags(flag)
                        end
                    end
                end
                if ext.include then
                    enable = target:has_cincludes(ext.include, {
                        configs = {
                            cflags = ext.flags
                        }
                    }) == true
                end
                opt:enable(enable, {
                    force = true
                })
                if enable then
                    table.insert(result, ext.name)
                    for _, flag in ipairs(ext.flags) do
                        target:add("cxflags", flag)
                    end
                end
            elseif opt:enabled() then
                table.insert(result, ext.name)
                for _, flag in ipairs(ext.flags) do
                    target:add("cxflags", flag)
                end
            end
        end
    end
    return result
end

function _processIfBlock(str)
    function processor(optname, operator, ifBody, elseBody)
        optname = optname:lower():gsub("_", "-")
        local opt = project.option(optname)
        local enabled = false
        if opt then
            enabled = opt:enabled()
        end
        if (operator == "eq" and enabled) or (operator == "ne" and not enabled) then
            return _processIfBlock(ifBody:sub(2, -2):trim())
        elseif elseBody then
            return _processIfBlock(elseBody:sub(2, -2):trim())
        end
        return ""
    end
    return str:gsub('if %(vpx_config%("CONFIG_([%w_]+)"%)%s(%a%a)%s"yes"%) (%b{})%s+else (%b{})', processor):gsub(
        'if %(vpx_config%("CONFIG_([%w_]+)"%)%s(%a%a)%s"yes"%) (%b{})', processor)
end

--- read rtcd defines from perl file `parh`
---@param path string
---@return table<string,table>, table<string,string>, string
function _read_defs(path)
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
            local name, exts = line:match("^specialize qw/([%w_]+)%s(.+)/;$")
            if name and exts then
                if functions[name] then
                    table.join2(functions[name].vers, exts:split("%s"))
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

--- genrate and write rtcd header to `output`
---@param output string
---@param exts string[]
---@param functions Functions
---@param decls string
---@param aliases table<string,string>
function _write_header(output, arch, exts, functions, aliases, decls)
    local file = io.open(output, "w")

    try {function()
        local def_name = path.basename(output):upper():gsub("%-", "_")
        file:write(format(common_top, def_name, def_name))
        file:write(decls)
        file:write(common_middle)
        for name, info in pairs(functions) do
            local best
            for _, ext in ipairs(info.vers) do
                if table.contains(exts, ext) then
                    local funcname = name .. "_" .. ext
                    funcname = aliases[funcname] or funcname
                    file:write(info.rettype .. " " .. funcname .. "(" .. info.params .. ");\n")
                    best = funcname
                end
            end
            file:write("#define " .. name .. " " .. best .. "\n\n")
        end

        file:write(setup[arch].prefix)
        file:write(setup[arch].suffix)
        file:write(common_buttom)
    end, finally {function()
        file:close()
    end}}
end

function genrate(target, arch, exts, input, output)
    printf("generating " .. input .. " ... ")
    input = path.translate(vformat(input))
    output = path.translate(vformat(output))
    local functions, aliases, decls = _read_defs(input)

    _write_header(output, arch, exts, functions, aliases, decls)
    cprint("${green bright}ok${clear}")
end
