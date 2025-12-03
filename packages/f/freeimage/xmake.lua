package("freeimage")
    set_homepage("https://sourceforge.net/projects/freeimage/")
    set_description("FreeImage is a library project for developers who would like to support popular graphics image formats (PNG, JPEG, TIFF, BMP and others).")
    set_license("FreeImage Public License")

    add_urls("https://sourceforge.net/projects/freeimage/files/Source%20Distribution/$(version).zip", {version = function (version)
        return version .. "/FreeImage" .. version:gsub("%.", "")
    end})
    add_versions("3.18.0", "f41379682f9ada94ea7b34fe86bf9ee00935a3147be41b6569c9605a53e438fd")

    add_patches("3.18.0", "patches/3.18.0/use_external_deps.patch", "0cb578f1cd5a0bb15f3f946b249ab7d537241e20d49c3c5825756eed2f6884ac")
	add_patches("3.18.0", "patches/3.18.0/pluginbmp.patch",         "2029f95478c8ce77f83671fe8e1889c11caa04eef2584abf0cd0a9f6a7047db0")
    add_patches("3.18.0", "patches/3.18.0/pluginjpeg.patch",        "e8662a3bcb26194c104de131e621835bdc2ba295a8f9f64cc0e6f1fb66594337")
    add_patches("3.18.0", "patches/3.18.0/plugintiff.patch",        "0363ba3282a7c556965f530c5899b95db6d4861e3bf6ac7700d4309cd17decfe")
    add_patches("3.18.0", "patches/3.18.0/fix_typedef.patch",       "1e1fd08ae6d00616c2631a9dddda84ba5725836e0369b88424184a9da3cfac11")

    add_configs("rgb", {description = "Use RGB instead of BGR.", default = false})

    add_deps("jxrlib", "libjpeg-turbo", "libpng", "libraw <0.20", "libtiff", "openexr <3.0", "openjpeg", "zlib")
    add_deps("libwebp", {configs = {libwebpmux = true}})

    on_check("windows|x86", function (package)
        local msvc = package:toolchain("msvc")
        local vs = msvc:config("vs")
        if vs and tonumber(vs) < 2019 then
            raise("package(freeimage): MSVC 2019 and earlier are not supported.")
        end
    end)

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FREEIMAGE_LIB")
        end
    end)

    on_install("windows|!arm*", "macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            includes("@builtin/check")
            add_requires("jxrlib", "libjpeg-turbo", "libpng", "libraw", "libtiff", "libwebp", "openexr", "openjpeg", "zlib")
            option("rgb", {default = false})
            target("freeimage")
                set_kind("$(kind)")
                set_languages("c++11")

                add_includedirs("Source", "Source/FreeImage", "Source/FreeImageToolkit", "Source/Metadata")
                add_headerfiles("Source/FreeImage.h", "Source/FreeImageIO.h")
                add_files("Source/FreeImage/*.cpp", "Source/FreeImage/*.c")
                add_files("Source/FreeImageToolkit/*.cpp", "Source/Metadata/*.cpp")

                check_cincludes("Z_HAVE_UNISTD_H", "unistd.h")
                add_packages("jxrlib", "libjpeg-turbo", "libpng", "libraw", "libtiff", "libwebp", "openexr", "openjpeg", "zlib")
                if has_config("rgb") then
                    add_defines("FREEIMAGE_COLORORDER=1")
                end

                if is_plat("windows") then
                    add_files("FreeImage.rc")
                    add_defines("WIN32", "_CRT_SECURE_NO_DEPRECATE")
                    add_defines(is_kind("static") and "FREEIMAGE_LIB" or "FREEIMAGE_EXPORTS")
                else
                    add_defines("__ANSI__")
                end
        ]])
        import("package.tools.xmake").install(package, {rgb = package:config("rgb")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FreeImage_Initialise", {includes = "FreeImage.h"}))
    end)
