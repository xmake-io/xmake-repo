package("libcap")

    set_homepage("https://sites.google.com/site/fullycapable/")
    set_description("User-space interfaces to POSIX 1003.1e capabilities")

    set_urls("https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$(version).tar.xz")
    add_versions("2.27", "dac1792d0118bee6aae6ba7fb93ff1602c6a9bda812fd63916eee1435b9c486a")

    on_install("linux", function (package)
        if not package:config("shared") then
            io.replace("libcap/Makefile", "all: $(MINLIBNAME) $(STALIBNAME) libcap.pc", "all: $(STALIBNAME) libcap.pc", {plain = true})
            io.replace("libcap/Makefile", [[install: all
	mkdir -p -m 0755 $(FAKEROOT)$(INCDIR)/sys
	install -m 0644 include/sys/capability.h $(FAKEROOT)$(INCDIR)/sys
	mkdir -p -m 0755 $(FAKEROOT)$(LIBDIR)
	install -m 0644 $(STALIBNAME) $(FAKEROOT)$(LIBDIR)/$(STALIBNAME)
	install -m 0644 $(MINLIBNAME) $(FAKEROOT)$(LIBDIR)/$(MINLIBNAME)
	ln -sf $(MINLIBNAME) $(FAKEROOT)$(LIBDIR)/$(MAJLIBNAME)
	ln -sf $(MAJLIBNAME) $(FAKEROOT)$(LIBDIR)/$(LIBNAME)]], [[install: all
	mkdir -p -m 0755 $(FAKEROOT)$(INCDIR)/sys
	install -m 0644 include/sys/capability.h $(FAKEROOT)$(INCDIR)/sys
	mkdir -p -m 0755 $(FAKEROOT)$(LIBDIR)
	install -m 0644 $(STALIBNAME) $(FAKEROOT)$(LIBDIR)/$(STALIBNAME)]], {plain = true})
        end
        os.vrunv("make", {"install", "prefix=" .. package:installdir(), "lib=lib", "RAISE_SETFCAP=no"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cap_init", {includes = "sys/capability.h"}))
    end)
