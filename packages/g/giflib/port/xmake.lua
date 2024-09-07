set_project("giflib")

option("utils", {showmenu = true, default = false})

add_rules("mode.debug", "mode.release")

target("gif")
    set_kind("$(kind)")
    add_files(
        "dgif_lib.c",
        "egif_lib.c",
        "gifalloc.c",
        "gif_err.c",
        "gif_font.c",
        "gif_hash.c",
        "openbsd-reallocarray.c"
    )

    add_headerfiles("gif_lib.h")

    if is_plat("windows") then
        add_files("gif_font.c", {defines = "strtok_r=strtok_s"})
        if is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end
    end
target_end()

if has_config("utils") then
    if is_plat("windows") then
        add_requires("cgetopt")
    end

    target("utils")
        set_kind("$(kind)")
        add_files("getarg.c", "qprintf.c", "quantize.c")
        add_deps("gif")
        if is_plat("windows") and is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end

    for _, tool in ipairs({"gif2rgb", "gifbuild", "gifclrmp", "giffix", "giftext", "giftool"}) do
        target(tool)
            set_kind("binary")
            add_files(tool .. ".c")
            add_deps("utils")
            if is_plat("windows") then
                add_packages("cgetopt")
            end
    end
end
