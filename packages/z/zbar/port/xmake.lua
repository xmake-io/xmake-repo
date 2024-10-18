add_rules("mode.debug", "mode.release")

if is_plat("macosx") then
    add_requires("libiconv", {system = true})
else
    add_requires("libiconv")
end

-- add options
option("enable_codebar")
    set_default(true)
    set_description("whether to build support for Codabar symbology")
    set_configvar("ENABLE_CODABAR", "1")
option_end()
if has_config("enable_codebar") then set_configvar("ENABLE_CODABAR", 1) end

option("enable_code128")
    set_default(true)
    set_description("whether to build support for Code 128 symbology")
option_end()
if has_config("enable_code128") then set_configvar("ENABLE_CODE128", 1) end

option("enable_code39")
    set_default(true)
    set_description("whether to build support for Code 39 symbology")
option_end()
if has_config("enable_code39") then set_configvar("ENABLE_CODE39", 1) end

option("enable_code93")
    set_default(true)
    set_description("whether to build support for Code 93 symbology")
option_end()
if has_config("enable_code93") then set_configvar("ENABLE_CODE93", 1) end

option("enable_databar")
    set_default(true)
    set_description("whether to build support for DataBar symbology")
option_end()
if has_config("enable_databar") then set_configvar("ENABLE_DATABAR", 1) end

option("enable_ean")
    set_default(true)
    set_description("whether to build support for EAN symbologies")
option_end()
if has_config("enable_ean") then set_configvar("ENABLE_EAN", 1) end

option("enable_i25")
    set_default(true)
    set_description("whether to build support for Interleaved 2 of 5 symbology")
option_end()
if has_config("enable_i25") then set_configvar("ENABLE_I25", 1) end

option("enable_pdf417")
    set_default(false)
    set_description("whether to build support for PDF417 symbology (incomplete)")
option_end()
if has_config("enable_pdf417") then set_configvar("ENABLE_PDF417", 1) end

option("enable_qrcode")
    set_default(true)
    set_description("whether to build support for QR Code")
option_end()
if has_config("enable_qrcode") then set_configvar("ENABLE_QRCODE", 1) end

option("enable_sqcode")
    set_default(true)
    set_description("whether to build support for SQ Code")
option_end()
if has_config("enable_sqcode") then set_configvar("ENABLE_SQCODE", 1) end

option("vers")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("vers") then
    set_configvar("VERSION", get_config("vers"))
    set_configvar("PACKAGE_VERSION", get_config("vers"))
    set_configvar("PACKAGE_STRING", "zbar " .. get_config("vers"))
    
    local vers = get_config("vers"):split("%.")
    major_ver = vers[1] or ""
    minor_ver = vers[2] or ""
    patch_ver = vers[3] or ""
    set_configvar("ZBAR_VERSION_MAJOR", major_ver, {quote = false})
    set_configvar("ZBAR_VERSION_MINOR", minor_ver, {quote = false})
    set_configvar("ZBAR_VERSION_PATCH", patch_ver, {quote = false})
end

option("LIB_VERSION")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("LIB_VERSION") then
    local lib_vers = get_config("LIB_VERSION")

    local cur = lib_vers:match("([^:]+)")
    local age = lib_vers:match(".*:(.*)$")
    local major = tonumber(cur) - tonumber(age)
    local minor = tonumber(age)
    local revision = lib_vers:match("^[^:]*:([^:]*):.*$")

    set_configvar("LIB_VERSION_MAJOR", major, {quote = false})
    set_configvar("LIB_VERSION_MINOR", minor, {quote = false})
    set_configvar("LIB_VERSION_REVISION", revision, {quote = false})
end

set_configvar("PACKAGE", "zbar")
set_configvar("PACKAGE_NAME", "zbar")
set_configvar("PACKAGE_TARNAME", "zbar")
set_configvar("PACKAGE_BUGREPORT", "mchehab+huawei@kernel.org")
set_configvar("PACKAGE_URL", "")

includes("@builtin/check")

-- config.h variables
configvar_check_cincludes("HAVE_SYS_TIME_H", "sys/time.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")

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

    set_configdir("include")
    add_configfiles("include/(config.h.in)", {filename = "config.h"})

    add_files(
            "zbar/config.c",
            "zbar/error.c", 
            "zbar/symbol.c",
            "zbar/image.c", 
            "zbar/convert.c",
            "zbar/refcnt.c", 
            "zbar/window.c", 
            "zbar/video.c",
            "zbar/img_scanner.c", 
            "zbar/scanner.c",
            "zbar/decoder.c", 
            "zbar/misc.c",
            "zbar/sqcode.c")
    if has_config("enable_ean") then
        add_files("zbar/decoder/ean.c")
    end
    if has_config("enable_databar") then
        add_files("zbar/decoder/databar.c")
    end
    if has_config("enable_code128") then
        add_files("zbar/decoder/code128.c")
    end
    if has_config("enable_code93") then
        add_files("zbar/decoder/code93.c")
    end
    if has_config("enable_code39") then
        add_files("zbar/decoder/code39.c")
    end
    if has_config("enable_codebar") then
        add_files("zbar/decoder/codabar.c")
    end
    if has_config("enable_i25") then
        add_files("zbar/decoder/i25.c")
    end
    if has_config("enable_pdf417") then
        add_files("zbar/decoder/pdf417.c")
    end
    if has_config("enable_qrcode") then
        add_files("zbar/decoder/qr_finder.c", "zbar/qrcode/*.c")
    end
    if has_config("enable_sqcode") then
        add_files("zbar/decoder/sq_finder.c")
    end
    
    -- "null" implementation for window module and video module
    add_files("zbar/window/null.c", "zbar/video/null.c", "zbar/processor/null.c")
    
    if is_plat("windows", "mingw") then
        add_files("zbar/libzbar.rc")
    end
