package("verilator")
    set_kind("toolchain")
    set_homepage("https://verilator.org")
    set_description("Verilator open-source SystemVerilog simulator and lint system")

    add_urls("https://github.com/verilator/verilator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/verilator/verilator.git")
    add_versions("2023.1.10", "5fce23e90d2a721bb712dc9aacde594558489dda")

    -- wait for next release with cmake
--    add_versions("v5.004", "7d193a09eebefdbec8defaabfc125663f10cf6ab0963ccbefdfe704a8a4784d2")

    add_deps("bison", "flex")
    add_deps("python 3.x", {kind = "binary"})

    if is_plat("windows") then
        add_deps("cmake")
    else
        add_deps("autoconf", "automake", "libtool")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_install("linux", "macosx", function (package)
        os.vrun("autoconf")
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("verilator --version")
    end)
