option("robust_mutex", {default = false})
option("tools", {default = false})

add_rules("mode.debug", "mode.release")

target("lmdb")
    set_kind("$(kind)")
    add_files("mdb.c", "midl.c")
    add_headerfiles("lmdb.h")

    add_defines("MDB_USE_ROBUST=" .. (has_config("robust_mutex") and "1" or "0"))

    if is_plat("windows") then
        add_syslinks("Advapi32")
        if is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

if has_config("tools") and (not is_plat("windows")) then
    for _, name in ipairs({"mdb_stat", "mdb_copy", "mdb_dump", "mdb_load"}) do
        target(name)
            set_kind("binary")
            add_files(name .. ".c")
            add_deps("lmdb")
    end
end
