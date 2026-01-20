option("bzip2", {default = false})

add_rules("mode.debug", "mode.release")

add_rules("utils.install.cmake_importfiles")

add_requires("zlib")
if has_config("bzip2") then
    add_requires("bzip2")
end

target("minizip")
    set_kind("$(kind)")
    add_files("zip.c", "unzip.c", "mztools.c", "ioapi.c")
    add_headerfiles("crypt.h", "zip.h", "unzip.h", "ioapi.h", "mztools.h", {prefixdir = "minizip"})

    add_packages("zlib")
    if has_config("bzip2") then
        add_packages("bzip2")
        add_defines("HAVE_BZIP2=1")
    end

    if is_plat("windows") then
        add_files("iowin32.c")
        add_headerfiles("iowin32.h", {prefixdir = "minizip"})
    else
        add_defines("_LARGEFILE64_SOURCE=1", "_FILE_OFFSET_BITS=64")
    end

    on_config(function(target)
        if not target:is_plat("windows") then
            local snippet = target:has_cfuncs("fopen64", {includes = "stdio.h", configs = {languages = "c11"}})
            if not snippet then
                target:add("defines", "IOAPI_NO_64")
            end
        end
    end)
