package("libopenmpt")
    set_homepage("https://openmpt.org/")
    set_description("a library to render tracker music (MOD, XM, S3M, IT MPTM and dozens of other legacy formats) to a PCM audio stream")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/OpenMPT/openmpt/archive/refs/tags/libopenmpt-$(version).tar.gz")
    add_urls("https://github.com/OpenMPT/openmpt.git", {alias = "git"})

    add_versions("0.8.4", "97530b25f88564fba8128333580ca0b12ac52c0c11c18ea5b8882a23176afa76")

    add_versions("git:0.8.4", "libopenmpt-0.8.4")

    add_deps("zlib", "mpg123", "libvorbis")

    on_install(function (package)
        io.replace("libopenmpt/libopenmpt_config.h", "defined(LIBOPENMPT_USE_DLL)", package:config("shared") and "1" or "0", {plain = true})
        if package:is_plat("windows") then
            io.replace("libopenmpt/libopenmpt_config.h", "#if defined(_MSC_VER) && !defined(_DLL)", "#if 0", {plain = true})
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("openmpt_get_library_version", {includes = "libopenmpt/libopenmpt.h"}))
    end)
