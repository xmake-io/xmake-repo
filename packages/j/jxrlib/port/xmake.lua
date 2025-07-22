option("tools", {default = false})

add_rules("mode.release", "mode.debug", "jxrlib")

add_includedirs(
    "common/include",
    "image/sys",
    "jxrgluelib",
    "jxrtestlib"
)

add_headerfiles("common/include/*.h", "image/sys/windowsmediaphoto.h", {prefixdir = "jxrlib"})

target("jpegxr")
    set_kind("$(kind)")
    add_files("image/**.c")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

target("jxrglue")
    set_kind("$(kind)")
    add_files("jxrgluelib/*.c", "jxrtestlib/*.c")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    add_deps("jpegxr")

    add_headerfiles(
        "jxrgluelib/JXRGlue.h",
        "jxrgluelib/JXRMeta.h",
        "jxrtestlib/JXRTest.h", {prefixdir = "jxrlib"}
    )

target("JxrEncApp")
    add_rules("tools")
    add_files("jxrencoderdecoder/JxrEncApp.c")

target("JxrDecApp")
    add_rules("tools")
    add_files("jxrencoderdecoder/JxrDecApp.c")

rule("jxrlib")
    on_config(function (target)
        target:add("defines", "DISABLE_PERF_MEASUREMENT")
        if target:is_plat("windows", "mingw", "msys") then
            target:add("defines", "WIN32")
        else
            target:add("defines", "__ANSI__")
        end
        if target:check_bigendian() then
            target:add("defines", "_BIG__ENDIAN_")
        end

        if not target:has_tool("cxx", "cl") then
            target:add("cxflags",
                "-Wno-error=implicit-function-declaration",
                "-Wno-endif-labels",
                -- https://gcc.gnu.org/gcc-14/porting_to.html#incompatible-pointer-types
                "-Wno-incompatible-pointer-types"
            )
        end
    end)

rule("tools")
    on_load(function (target)
        if not get_config("tools") then
            target:set("enabled", false)
            return
        end

        target:add("kind", "binary")
        target:add("deps", "jxrglue")
    end)
