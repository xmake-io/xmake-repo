option("tools", {default = false})

add_rules("mode.debug", "mode.release")

add_requires("gklib")
add_packages("gklib")

add_includedirs("include")

target("metis")
    set_kind("$(kind)")
    add_files("libmetis/*.c")
    add_headerfiles("include/metis.h")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

if has_config("tools") then
    target("tool_lib")
        set_kind("static")
        add_files(
            "programs/io.c",
            "programs/stat.c",
            "programs/smbfactor.c"
        )

        on_install(function(target) end)

    target("gpmetis")
        set_kind("binary")
        add_files("programs/gpmetis.c", "programs/cmdline_gpmetis.c")
        add_deps("tool_lib")

    target("ndmetis")
        set_kind("binary")
        add_files("programs/ndmetis.c", "programs/cmdline_ndmetis.c")
        add_deps("tool_lib")

    target("mpmetis")
        set_kind("binary")
        add_files("programs/mpmetis.c", "programs/cmdline_mpmetis.c")
        add_deps("tool_lib")

    target("m2gmetis")
        set_kind("binary")
        add_files("programs/m2gmetis.c", "programs/cmdline_m2gmetis.c")
        add_deps("tool_lib")

    target("graphchk")
        set_kind("binary")
        add_files("programs/graphchk.c")
        add_deps("tool_lib")

    target("cmpfillin")
        set_kind("binary")
        add_files("programs/cmpfillin.c")
        add_deps("tool_lib")
end
