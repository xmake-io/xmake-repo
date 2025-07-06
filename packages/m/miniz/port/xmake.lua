option("ver", {default = "2.1.0"})

add_rules("mode.debug", "mode.release")

local export_file = "miniz_export.h"

target("miniz")
    set_kind("$(kind)")
    add_files("miniz.c", "miniz_zip.c", "miniz_tinfl.c", "miniz_tdef.c")
    add_headerfiles("miniz.h", "miniz_common.h", "miniz_zip.h", "miniz_tinfl.h", "miniz_tdef.h", {prefixdir = "miniz"})

    on_load(function (target)
        import("core.base.semver")
        import("core.project.rule")

        local version = import("core.base.semver").new(get_config("ver"))
        target:set("version", version, {soname = true})
        if version:lt("2.2.0") then
            if target:is_plat("windows") and target:is_shared() then
                local rule = rule.rule("utils.symbols.export_all")
                target:rule_add(rule)
                target:extraconf_set("rules", "utils.symbols.export_all")
            end
        else
            local string = "#define MINIZ_EXPORT"
            if target:is_plat("windows") and target:is_shared() then
                string = string .. " __declspec(dllexport)"
            end
    
            io.writefile(export_file, string)
            target:add("headerfiles", export_file, {prefixdir = "miniz"})
        end
    end)

    after_build(function (target)
        if target:is_plat("windows") then
            if target:is_shared() then
                io.writefile(export_file, "#define MINIZ_EXPORT __declspec(dllimport)")
            elseif target:is_static() then
                io.writefile(export_file, "#define MINIZ_EXPORT")
            end
        end
    end)
