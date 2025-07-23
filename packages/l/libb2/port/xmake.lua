option("openmp", {default = false})
option("sse", {default = false})

if has_config("openmp") then
    add_requires("openmp")
    add_packages("openmp")
end

add_rules("mode.debug", "mode.release")

target("b2")
    set_kind("$(kind)")
    add_headerfiles("src/blake2.h")
    add_files("src/blake2bp.c", "src/blake2sp.c")

    if has_config("sse") then
        add_files(
            "src/blake2s.c",
            "src/blake2b.c"
        )
        add_vectorexts("all")
    else
        add_files(
            "src/blake2s-ref.c",
            "src/blake2b-ref.c"
        )
    end

    if is_kind("shared") then
        add_defines("BLAKE2_DLL_EXPORTS")
        add_defines("BLAKE2_DLL", {public = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end
