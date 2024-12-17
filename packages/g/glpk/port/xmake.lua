add_rules("mode.debug", "mode.release")

add_requires("zlib")

target("glpk")
    set_kind("$(kind)")
    add_files("src/**.c|zlib/*.c")
    add_includedirs(
        "src",
        "src/amd",
        "src/api",
        "src/bflib",
        "src/colamd",
        "src/draft",
        "src/env",
        "src/intopt",
        "src/minisat",
        "src/misc",
        "src/mpl",
        "src/npp",
        "src/simplex"
    )

    if is_kind("shared") then
        add_files("*.def")
    end

    if is_plat("windows") then
        add_defines("__WOE__=1")
    end

    add_packages("zlib")

    add_headerfiles("src/glpk.h")
