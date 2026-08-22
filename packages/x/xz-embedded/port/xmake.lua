add_rules("mode.debug", "mode.release")

set_languages("c11")

local linux_root = path.join(os.projectdir(), "../linux")
local xz_lib_dir = path.join(linux_root, "lib/xz")
local xz_inc_dir = path.join(linux_root, "include/linux")

add_includedirs(xz_inc_dir)
add_includedirs(".")

add_defines(
    "XZ_DEC_X86",
    "XZ_DEC_ARM",
    "XZ_DEC_ARMTHUMB",
    "XZ_DEC_ARM64",
    "XZ_DEC_RISCV",
    "XZ_DEC_POWERPC",
    "XZ_DEC_IA64",
    "XZ_DEC_SPARC",
    "XZ_USE_CRC64",
    "XZ_USE_SHA256",
    "XZ_DEC_ANY_CHECK",
    "XZ_DEC_CONCATENATED")

target("xz_common")
    set_kind("$(kind)")
    add_files(
        path.join(xz_lib_dir, "xz_crc32.c"),
        path.join(xz_lib_dir, "xz_crc64.c"),
        path.join(xz_lib_dir, "xz_sha256.c"),
        path.join(xz_lib_dir, "xz_dec_stream.c"),
        path.join(xz_lib_dir, "xz_dec_lzma2.c"),
        path.join(xz_lib_dir, "xz_dec_bcj.c")
    )
    add_headerfiles(path.join(xz_inc_dir, "(**.h)"))

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
