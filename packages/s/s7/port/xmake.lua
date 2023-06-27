add_rules("mode.release", "mode.debug")

option("gmp", {default = false, defines = "WITH_GMP"})

if has_config("gmp") then
    add_requires("gmp")
end

target("libs7") do
    set_kind("$(kind)")
    set_basename("s7")
    add_files("s7.c")
    add_headerfiles("s7.h")
    add_includedirs(".", {public = true})
    add_options("gmp")
    if is_plat("windows") then
        set_languages("c11")
    end
    add_packages("gmp")
    if is_mode("debug") then
        add_defines("S7_DEBUGGING")
    end
end

target("s7") do
    set_kind("binary")
    add_defines("WITH_MAIN")
    add_files("s7.c")
    add_headerfiles("s7.h")
    add_includedirs(".", {public = true})
    add_options("gmp")
    if is_plat("windows") then
        set_languages("c11")
    end
    add_packages("gmp")
    if is_mode("debug") then
        add_defines("S7_DEBUGGING")
    end
    if not is_plat("macosx") then
        add_ldflags("-static", "-static-libgcc", {force = true})
    end
    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
end
