package("timeh")
    set_kind("binary")
    set_homepage("https://github.com/Monjaris/timeh")
    set_description("A simple terminal time utility")
    set_license("MIT")

    add_urls("https://github.com/Monjaris/timeh/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.5.0", "f146f4b17ff83ef72ca7ea6958fda016a660e38732f9f9e452f176a23c233d85")

    on_install("@windows", "@linux", "@macosx", "@bsd", function(package)
        io.replace("xmake.lua", [[set_toolchains(".gnu")]], [[if is_host("windows") then
    set_toolchains(".gnu")
end]], {plain = true})
        io.replace("xmake.lua", [[    set_kind("binary")]], [[    set_kind("binary")
    if is_plat("mingw", "msys") or is_host("windows") then
        add_syslinks("stdc++exp")
    end]], {plain = true})
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        os.vexec("timeh")
    end)
