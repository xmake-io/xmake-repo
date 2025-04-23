add_rules("mode.debug", "mode.release")

option("enable_float", {default = true, showmenu = true})

option("HAS_OPEN_MEMSTREAM")
    add_cfuncs("open_memstream")
    add_cincludes("stdio.h")
    add_defines("_GNU_SOURCE")

option("HAS_FOPENCOOKIE")
    add_cfuncs("fopencookie")
    add_cincludes("stdio.h")
    add_defines("_GNU_SOURCE")

option("HAS_FUNOPEN")
    add_cfuncs("funopen")
    add_cincludes("stdio.h")
    add_defines("_GNU_SOURCE")

target("tinycbor")
    set_kind("$(kind)")
    add_files("src/cbor*.c")
    add_includedirs("src")

    if not has_config("HAS_OPEN_MEMSTREAM") then
        if has_config("HAS_FOPENCOOKIE") and has_config("HAS_FUNOPEN") then
            add_files("src/open_memstream.c")
        else
            add_defines("WITHOUT_OPEN_MEMSTREAM")
        end
    end

    if not has_config("enable_float") then
        add_defines("CBOR_NO_FLOATING_POINT")
    end
    if is_plat("mingw") and is_arch("i386") then
        add_vectorexts("all")
    end

    if is_plat("windows") and is_kind("shared") then
        add_defines("CBOR_API=__declspec(dllexport)")
    end

    add_headerfiles("src/cbor.h", "src/cborjson.h", "src/tinycbor-version.h")
