add_rules("mode.debug", "mode.release")

set_languages("c99")

add_defines("HAVE_STRING_H")

if is_plat("windows") then
    add_defines("_CRT_SECURE_NO_WARNINGS")
end

add_includedirs(".")

option("tools")
    set_default(true)
    set_showmenu(true)
    set_description("Build the udcli executable tool")

target("libudis86")
    set_kind("$(kind)")
    
    add_files("libudis86/*.c")

    if is_kind("shared") and is_plat("windows") then
        add_defines("_USRDLL", "LIBUDIS86_EXPORTS")
    end

    add_headerfiles("libudis86/*.h", {prefixdir = "libudis86"})
    add_headerfiles("udis86.h")

    on_load(function (target)
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print("Generating instruction tables...")
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        print(os.curdir())
        import("lib.detect.find_tool")
        local args = {
            path.join(os.curdir(), "scripts", "ud_itab.py"),
            path.join(os.curdir(), "docs", "x86", "optable.xml"),
            path.join(os.curdir(), "libudis86")
        }
        local python = find_tool("python")
        os.vrunv(python.program, args)
    end)

target("udcli")
    set_kind("binary")
    set_enabled(has_config("tools"))

    add_files("udcli/udcli.c")
    add_deps("libudis86")
