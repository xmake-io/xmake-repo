add_rules("mode.debug", "mode.release")

add_requires("libiconv")

-- add options
option("symbologies")
    set_description("Select symbologies to compile")
option_end()

option("vers")
    set_default("")
    set_showmenu(true)
option_end()
if has_config("vers") then
    set_version(get_config("vers"))

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

    local symbologies = {{name = "ean",     files = {"zbar/decoder/ean.c"}},
                        {name = "databar", files = {"zbar/decoder/databar.c"}},
                        {name = "code128", files = {"zbar/decoder/code128.c"}},
                        {name = "code93",  files = {"zbar/decoder/code93.c"}},
                        {name = "code39",  files = {"zbar/decoder/code39.c"}},
                        {name = "codabar", files = {"zbar/decoder/codabar.c"}},
                        {name = "i25",     files = {"zbar/decoder/i25.c"}},
                        {name = "qrcode",  files = {"zbar/decoder/qr_finder.c", "zbar/qrcode/*.c"}},
                        {name = "sqcode",  files = {"zbar/decoder/sq_finder.c"}},
                        {name = "pdf417",  files = {"zbar/decoder/pdf417.c"}}}
    local enabled_symbologies = get_config("symbologies")
    if enabled_symbologies then
        for _, symbology in ipairs(symbologies) do
            if enabled_symbologies:find(symbology.name) or enabled_symbologies:find("all") then
                add_files(symbology.files)
                set_configvar("ENABLE_" .. symbology.name:upper(), 1)
            end
        end
    end

    -- "null" implementation for window module and video module
    add_files("zbar/window/null.c", "zbar/video/null.c", "zbar/processor/null.c")
    
    if is_plat("windows", "mingw") then
        add_files("zbar/libzbar.rc")
    end
