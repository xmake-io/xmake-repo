package("blook")
    set_description("A modern C++ library for hacking.")
    set_license("GPL-3.0")

    add_urls("https://github.com/std-microblock/blook.git")

    add_versions("2025.04.04", "997b6a288fb2e8cd9b9e2dec0c15c050a52139d3")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    add_deps("zasm 916f28f882801c048eaececc2466c8fdc17653fa")

    on_install("windows|!arm*", function (package)
        import("package.tools.xmake").install(package, {}, {target = "blook"})
    end)
