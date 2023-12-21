package("libuuid")
    set_homepage("https://sourceforge.net/projects/libuuid")
    set_description("Portable uuid C library")
    set_license("BSD-3-Clause")

    set_urls("https://sourceforge.net/projects/libuuid/files/libuuid-$(version).tar.gz",
             "https://github.com/xmake-mirror/libuuid/releases/download/$(version)/libuuid-$(version).tar.gz",
             "https://git.code.sf.net/p/libuuid/code.git")

    add_versions("1.0.3", "46af3275291091009ad7f1b899de3d0cea0252737550e7919d17237997db5644")

    on_install("linux", "macosx", "bsd", "android", "iphoneos", "wasm", "cross", function(package)
        io.writefile("xmake.lua", [[
            includes("check_cfuncs.lua")
            add_rules("mode.debug", "mode.release")
            target("uuid")
                set_kind("$(kind)")
                add_files("*.c|test_*.c")
                add_headerfiles("*.h", {prefixdir = "uuid"})
                add_rules("utils.install.pkgconfig_importfiles", {filename = "uuid.pc"})
                check_cfuncs("HAVE_USLEEP", "usleep", {includes = "unistd.h"})
                check_cfuncs("HAVE_FTRUNCATE", "ftruncate", {includes = "unistd.h"})
                check_cfuncs("HAVE_GETTIMEOFDAY", "gettimeofday", {includes = "sys/time.h"})
                check_cfuncs("HAVE_MEMSET", "memset", {includes = "string.h"})
                check_cfuncs("HAVE_SOCKET", "socket", {includes = "sys/socket.h"})
                check_cfuncs("HAVE_STRTOUL", "strtoul", {includes = "stdlib.h"})
                check_cfuncs("HAVE_SRANDOM", "srandom", {includes = "stdlib.h"})
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_csnippets({
            test = [[
                void test() {
                    uuid_t buf;
                    char str[100];
                    uuid_generate(buf);
	                uuid_unparse(buf, str);
                }
            ]]
        }, {configs = {languages = "c11"}, includes = "uuid/uuid.h"}))
    end)
