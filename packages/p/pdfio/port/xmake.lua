add_rules("mode.debug", "mode.release")

add_requires("zlib")
add_packages("zlib")

target("pdfio")
    set_kind("$(kind)")
    add_files("pdfio-*.c", "ttf.c")
    add_headerfiles("pdfio.h")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end
