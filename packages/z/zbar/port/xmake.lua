add_rules("mode.debug", "mode.release")

add_requires("libiconv")

-- add options
option("enable-codes")
    set_default("ean,databar,code128,code93,code39,codabar,i25,qrcode,sqcode")
    set_description("Select symbologies to compile",
                    "default=ean,databar,code128,code93,code39,codabar,i25,qrcode,sqcode")
option_end()

local codes =  {{name = "ean",     description = "EAN symbologies"},
                {name = "databar", description = "DataBar symbology"},
                {name = "code128", description = "name 128 symbology"},
                {name = "code93",  description = "name 93 symbology"},
                {name = "code39",  description = "name 39 symbology"},
                {name = "codabar", description = "Codabar symbology"},
                {name = "i25",     description = "Interleaved 2 of 5 symbology"},
                {name = "qrcode",  description = "QR name"},
                {name = "sqcode",  description = "SQ name"},
                {name = "pdf417",  description = "PDF417 symbology (incomplete)"}}
for _, code in ipairs(codes) do
    option(code.name)
        -- set_default(false)
        add_deps("enable-codes")
        set_description("whether to build support for " .. code.description)

        on_check(function (option)
            local enabled_codes = option:dep("enable-codes"):value()
            if enabled_codes then
                if enabled_codes:find(code.name) or enabled_codes:find("all") then
                    option:enable(true)
                end
            end
        end)    
    option_end()
    
    if has_config(code.name) then set_configvar("ENABLE_" .. code.name:upper(), 1) end
end

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
    if has_config("ean") then
        add_files("zbar/decoder/ean.c")
    end
    if has_config("databar") then
        add_files("zbar/decoder/databar.c")
    end
    if has_config("code128") then
        add_files("zbar/decoder/code128.c")
    end
    if has_config("code93") then
        add_files("zbar/decoder/code93.c")
    end
    if has_config("code39") then
        add_files("zbar/decoder/code39.c")
    end
    if has_config("codabar") then
        add_files("zbar/decoder/codabar.c")
    end
    if has_config("i25") then
        add_files("zbar/decoder/i25.c")
    end
    if has_config("pdf417") then
        add_files("zbar/decoder/pdf417.c")
    end
    if has_config("qrcode") then
        add_files("zbar/decoder/qr_finder.c", "zbar/qrcode/*.c")
    end
    if has_config("sqcode") then
        add_files("zbar/decoder/sq_finder.c")
    end
    
    -- "null" implementation for window module and video module
    add_files("zbar/window/null.c", "zbar/video/null.c", "zbar/processor/null.c")
    
    if is_plat("windows", "mingw") then
        add_files("zbar/libzbar.rc")
    end
