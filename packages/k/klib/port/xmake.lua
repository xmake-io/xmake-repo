option("url", {default = false})
option("thread", {default = false})
option("open", {default = false})

add_rules("mode.release", "mode.debug")

add_requires("zlib")
if has_config("url") then
    add_requires("libcurl")
    add_packages("libcurl")
end

if has_config("thread") then
    add_syslinks("pthread")
end

target("klib")
    set_kind("$(kind)")
    add_files("kmath.c", {defines = "M_SQRT2=1.41421356237309504880"})
    add_files("*.c|rand48.c|kurl.c|kthread.c|kopen.c|ksw.c")
    add_includedirs(os.projectdir())
    add_packages("zlib")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    add_headerfiles("*.h|unistd.h|kurl.h|kthread.h|kopen.h|ksw.h")

    if has_config("url") then
        add_files("kurl.c")
        add_headerfiles("kurl.h")
    end

    if has_config("thread") then
        add_files("kthread.c")
        add_headerfiles("kthread.h")
    end

    if has_config("open") then
        add_files("kopen.c")
        add_headerfiles("kopen.h")
    end

    if is_arch("x64", "x86", "x86_64") then
        add_files("ksw.c")
        add_headerfiles("ksw.h")
    end
