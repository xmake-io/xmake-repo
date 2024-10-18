add_rules("mode.debug", "mode.release")

add_requires("libiconv")

target("zbar")
    set_kind("$(kind)")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    add_packages("libiconv")
    
    add_includedirs("include")
    add_includedirs("zbar")

    add_headerfiles("include/zbar.h")
    add_headerfiles("include/zbar/Scanner.h", "include/zbar/Decoder.h",
        "include/zbar/Exception.h", "include/zbar/Symbol.h", "include/zbar/Image.h",
        "include/zbar/ImageScanner.h", "include/zbar/Video.h", "include/zbar/Window.h",
        "include/zbar/Processor.h", {prefixdir = "zbar"})

    add_files(
            "zbar/config.c",
            "zbar/error.c", 
            "zbar/symbol.c",
            "zbar/image.c", 
            "zbar/convert.c",
            "zbar/processor.c", 
            "zbar/processor/lock.c",
            "zbar/refcnt.c", 
            "zbar/window.c", 
            "zbar/video.c",
            "zbar/img_scanner.c", 
            "zbar/scanner.c",
            "zbar/decoder.c", 
            "zbar/misc.c",
            "zbar/sqcode.c")
    -- pdf417 is incomplete
    add_files("zbar/decoder/*.c|pdf417*.c")
    add_files("zbar/qrcode/*.c")
    -- "null" implementation for window module and video module
    add_files("zbar/processor/null.c", "zbar/window/null.c", "zbar/video/null.c")
    if is_plat("windows", "mingw") then
        add_files("zbar/processor/win.c", "zbar/libzbar.rc")
    else 
        add_files("zbar/processor/posix.c")
    end
