add_rules("mode.debug", "mode.release", "mode.releasedbg", "mode.minsizerel")

option("unicode", {showmenu = true,  default = true})

target("ocilib")
    set_kind("$(kind)")
    add_files("src/*.c")
    add_includedirs("src")
    add_includedirs("include", {public = true})
    add_headerfiles("include/(**.h)", "include/(**.hpp)")

    if is_kind("static") then
        add_defines("OCI_LIB_LOCAL_COMPILE", {public = true})
    end

    if is_plat("windows") and is_kind("shared") then
        add_files("proj/dll/main.rc")
        add_defines("OCI_EXPORT")
    end

    if has_config("unicode") then
        add_defines("OCI_CHARSET_WIDE")
    else
        add_defines("OCI_CHARSET_ANSI")
    end

    add_defines("OCI_IMPORT_RUNTIME")
