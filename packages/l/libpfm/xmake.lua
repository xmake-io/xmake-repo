package("libpfm")

    set_homepage("http://perfmon2.sourceforge.net/")
    set_description("improving performance monitoring on Linux")
    set_license("MIT")

    add_urls("http://sourceforge.net/projects/perfmon2/files/libpfm4/libpfm-$(version).tar.gz")
    add_versions("4.11.0", "5da5f8872bde14b3634c9688d980f68bda28b510268723cc12973eedbab9fecc")

    on_install("linux", function (package)
        if package:config("shared") then
            io.replace("lib/Makefile", "TARGETS=$(ALIBPFM)", "TARGETS=", {plain = true})
            io.replace("lib/Makefile", "$(INSTALL) -m 644 $(ALIBPFM) $(DESTDIR)$(LIBDIR)", "", {plain = true})
        end
        local args = {}
        table.insert(args, "CC=" .. package:build_getenv("cc"))
        table.insert(args, "DBG=")
        table.insert(args, "CONFIG_PFMLIB_DEBUG=" .. (package:debug() and "y" or "n"))
        table.insert(args, "CONFIG_PFMLIB_SHARED=" .. (package:config("shared") and "y" or "n"))
        table.insert(args, "CONFIG_PFMLIB_NOPYTHON=y")
        table.insert(args, "PREFIX=" .. package:installdir())
        os.vrunv("make", table.join({"lib"}, args))
        os.vrunv("make", table.join({"install"}, args))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pfm_initialize", {includes = "perfmon/pfmlib.h"}))
    end)
