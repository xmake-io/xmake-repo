add_rules("mode.release", "mode.debug")

option("gmp", {default = false, defines = "WITH_GMP"})

if is_config("gmp", true) then
    add_requires("gmp")
end

target("libs7") do
    set_basename("s7")
    set_optimize("faster")
    add_files("s7.c")
    add_headerfiles("s7.h")
    add_includedirs(".", {public = true})
    add_options("gmp")
    set_kind("$(kind)")
    if is_plat("windows") then
        set_languages("c11")
    end
    add_packages("gmp")
    if is_mode("debug") then
        add_defines("S7_DEBUGGING")
    end
end

target("s7") do
    set_optimize("faster")
    add_defines("WITH_MAIN")
    add_files("s7.c")
    add_headerfiles("s7.h")
    add_includedirs(".", {public = true})
    add_options("gmp")
    set_kind("binary")
    if is_plat("windows") then
        set_languages("c11")
    end
    add_packages("gmp")
    if is_mode("debug") then
        add_defines("S7_DEBUGGING")
    end
    add_ldflags("-static", "-static-libgcc", {force = true})
end
