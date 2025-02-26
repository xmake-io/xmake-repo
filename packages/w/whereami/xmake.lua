package("whereami")
    set_homepage("https://github.com/gpakosz/whereami")
    set_description("Locate the current running executable and the current running module/library on the file system 🔎")
    set_license("MIT")

    add_urls("https://github.com/gpakosz/whereami.git")
    add_versions("2024.08.26", "dcb52a058dc14530ba9ae05e4339bd3ddfae0e0e")

    on_install("!wasm", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("whereami")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/(*.h)")
                add_includedirs("src")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wai_getExecutablePath", {includes = "whereami.h"}))
    end)
