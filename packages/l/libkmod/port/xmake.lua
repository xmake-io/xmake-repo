add_rules("mode.debug", "mode.release")

target("kmod")
    set_kind("$(kind)")
    set_languages("gnu99")
    add_headerfiles("(libkmod/libkmod.h)")
    add_headerfiles("(libkmod/libkmod-index.h)")
    add_includedirs(".")
    add_defines("PATH_MAX=4096")
    add_defines("ANOTHER_BRICK_IN_THE")
    add_defines("SYSCONFDIR=\"/tmp\"")
    add_defines("secure_getenv=getenv")
    add_cflags("-include config.h")
    add_files(
        "libkmod/libkmod.c",
        "libkmod/libkmod-builtin.c",
        "libkmod/libkmod-file.c",
        "libkmod/libkmod-module.c",
        "libkmod/libkmod-config.c",
        "libkmod/libkmod-index.c",
        "libkmod/libkmod-elf.c",
        "libkmod/libkmod-list.c",
        "libkmod/libkmod-signature.c",
        "shared/array.c",
        "shared/scratchbuf.c",
        "shared/util.c",
        "shared/hash.c",
        "shared/strbuf.c")
