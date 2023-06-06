add_rules("mode.debug", "mode.release")

option("vers")
    set_default("")
    set_showmenu(true)
option_end()

if has_config("vers") then
    set_version(get_config("vers"))
end

target("cspice")
    set_kind("$(kind)")
    add_headerfiles("include/**.h")
    add_files("src/cspice/**.c")
target_end()
