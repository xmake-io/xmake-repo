option("libzip", {showmenu = true,  default = false})
option("minizip_ng", {showmenu = true,  default = false})
option("wide", {showmenu = true,  default = false})

add_rules("mode.debug", "mode.release")

add_requires("expat")

if has_config("libzip") then
    add_requires("libzip")
elseif has_config("minizip_ng") then
    add_requires("minizip-ng", {configs = {zlib = true}})
else
    add_requires("minizip")
end

target("xlsxio")
    set_kind("$(kind)")
    add_files("lib/*.c")
    add_includedirs("include")
    add_headerfiles("include/*.h")

    add_defines("BUILD_XLSXIO")
    if is_kind("shared") then
        add_defines("BUILD_XLSXIO_SHARED", {public = true})
    else
        add_defines("BUILD_XLSXIO_STATIC", {public = true})
    end

    if has_config("wide") then
        add_defines("XML_UNICODE", {public = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if has_config("libzip") then
        add_defines("USE_LIBZIP")
        add_packages("libzip")
    else
        add_defines("USE_MINIZIP")
        if has_config("minizip_ng") then
            add_defines("USE_MINIZIP_NG")
            add_packages("minizip-ng")
        else
            add_packages("minizip")
        end
    end

    add_packages("expat")
