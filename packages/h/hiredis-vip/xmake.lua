package("hiredis-vip")
    set_homepage("https://github.com/vipshop/hiredis-vip")
    set_description("Support redis cluster. Maintained and used at vipshop.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/vipshop/hiredis-vip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vipshop/hiredis-vip.git")

    add_versions("0.3.0", "84e0f9367fa25089fc073b7a8a0725043c48cccec827acf4555a63da68f36be5")

    add_deps("cmake")

    on_install("!windows and !mingw", function (package)
        -- Repair FreeBSD
        io.replace("hiutil.c", [[#include <sys/types.h>]], [[#include <sys/types.h>
#include <sys/socket.h>]], {plain = true})
        -- GCC15 workaround
        io.replace("command.c", [[#include "hiarray.h"]], [[#include "hiarray.h"
#include <stdlib.h>]], {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.cp(path.join(package:scriptdir(), "port", "cmakelists.txt"), "CMakeLists.txt")
        os.cp(path.join(package:scriptdir(), "port", "hiredis_vip.pc.in"), "hiredis_vip.pc.in")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("redisCommand", {includes = "hiredis-vip/hiredis.h"}))
    end)
