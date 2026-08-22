package("autotools")
    set_kind("binary")
    set_license("GPL-3.0-or-later")

    if is_subhost("msys") then
        add_deps("pacman::autotools")
    else
        add_deps("autoconf", "automake", "libtool")
    end

    on_install("@linux", "@macosx", "@bsd", "@msys", function (package)
    end)
