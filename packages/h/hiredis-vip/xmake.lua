package("hiredis-vip")
    set_homepage("https://github.com/vipshop/hiredis-vip")
    set_description("Support redis cluster. Maintained and used at vipshop.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/vipshop/hiredis-vip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vipshop/hiredis-vip.git")

    add_versions("0.3.0", "84e0f9367fa25089fc073b7a8a0725043c48cccec827acf4555a63da68f36be5")

    add_deps("autotools")

    on_install("linux", "macosx", "cross", "bsd", "mingw", "wasm", "android", function (package)
        -- GCC15 workaround
        io.replace("command.c", [[#include "hiarray.h"]], [[#include "hiarray.h"
#include <stdlib.h>]], {plain = true})
        -- Repair installation path
        io.replace("Makefile", "PREFIX?=/usr/local", "PREFIX?=" .. package:installdir(), {plain = true})
        -- Enforce installation only one type of library
        if package:config("shared") then
            io.replace("Makefile", [[$(INSTALL) $(STLIBNAME) $(INSTALL_LIBRARY_PATH)]], [[]], {plain = true})
        else
            io.replace("Makefile", [[
	$(INSTALL) $(DYLIBNAME) $(INSTALL_LIBRARY_PATH)/$(DYLIB_MINOR_NAME)
	cd $(INSTALL_LIBRARY_PATH) && ln -sf $(DYLIB_MINOR_NAME) $(DYLIB_MAJOR_NAME)
	cd $(INSTALL_LIBRARY_PATH) && ln -sf $(DYLIB_MAJOR_NAME) $(DYLIBNAME)]], [[]], {plain = true})
        end
        local configs = {}
        if package:is_debug() then
            table.insert(configs, "DEBUG=1")
        end
        import("package.tools.make").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("redisCommand", {includes = "hiredis-vip/hiredis.h"}))
    end)
