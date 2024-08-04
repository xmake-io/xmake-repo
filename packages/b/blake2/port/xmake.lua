option("openmp", {default = false})
option("sse", {default = false})
option("neno", {default = false})

if has_config("openmp") then
    add_requires("openmp")
    add_packages("openmp")
end

add_rules("mode.debug", "mode.release")

target("blake2")
    set_kind("$(kind)")
    add_headerfiles("ref/blake2.h")
    add_files("src/blake2bp.c", "src/blake2sp.c")

    if has_config("sse") then
        add_files(
            "sse/blake2b.c",
            "sse/blake2bp.c",
            "sse/blake2s.c",
            "sse/blake2sp.c",
            "sse/blake2xb.c",
            "sse/blake2xs.c"
        )
        add_vectorexts("all")
    elseif has_config("neno") then
        add_files(
            "neon/blake2b-neon.c",
            "neon/blake2bp.c",
            "neon/blake2s-neon",
            "neon/blake2xb.c",
            "neon/blake2sp.c",
            "neon/blake2xs.c"
        )
        add_vectorexts("all")
    else
        add_files(
            "ref/blake2bp-ref.c",
            "ref/blake2b-ref.c",
            "ref/blake2sp-refon",
            "ref/blake2s-ref.c",
            "ref/blake2xb-ref.c",
            "ref/blake2xs-ref.c"
        )
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end
