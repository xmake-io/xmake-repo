package("osip")

    set_homepage("http://www.gnu.org/software/osip/")
    set_description("A LGPL implementation of SIP")

    add_urls("https://mirrors.aliyun.com/gnu/osip/libosip2-$(version).tar.gz",
             "http://ftp.gnu.org/gnu/osip/libosip2-$(version).tar.gz")
    add_versions("5.2.1", "ee3784bc8e7774f56ecd0e2ca6e3e11d38b373435115baf1f1aa0ca0bfd02bf2")
    add_versions("5.1.2", "2bc0400f21a64cf4f2cbc9827bf8bdbb05a9b52ecc8e791b4ec0f1f9410c1291")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    on_install("windows", function(package)
        import("package.tools.msbuild")
        local name = path.filename(os.curdir())
        os.cd("..")
        local cur_dir = os.curdir() .. "\\"
        os.mv(cur_dir .. name, cur_dir .. "\\osip")
        os.cd(cur_dir .. "\\osip")
        local arch = package:is_arch("x64") and "x64" or "x86"
        local mode = package:debug() and "Debug" or "Release"
        local configs = { "osip.sln" }
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        local oldir = os.cd("platform/vsnet")
        -- add external function under windows:msvc
        -- @osip2.def
        --    osip_transaction_set_naptr_record @138
        -- @osipparser2.def
        --    osip_realloc @417
        --    osip_strcasestr @418
        --    __osip_uri_escape_userinfo @419
        local file = io.open("osip2.def", "a")
        if file then
            file:write("     osip_transaction_set_naptr_record @138\n")
            file:close()
        end
        local filep = io.open("osipparser2.def", "a")
        if filep then
            filep:write("     osip_realloc @417\n")
            filep:write("     osip_strcasestr @418\n")
            filep:write("     __osip_uri_escape_userinfo @419\n")
            filep:close()
        end
        msbuild.build(package, configs)
        os.cd(oldir)
        os.vcp("include/osip2/*.h", package:installdir("include/osip2"))
        os.vcp("include/osipparser2/*.h", package:installdir("include/osipparser2"))
        os.vcp("include/osipparser2/headers/*.h", package:installdir("include/osipparser2/headers"))
        if package:config("shared") then
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "osip2.lib"), package:installdir("lib"))
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "osipparser2.lib"), package:installdir("lib"))
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "osip2.dll"), package:installdir("lib"))
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "osipparser2.dll"), package:installdir("lib"))
        else
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "osip2.lib"), package:installdir("lib"))
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "osipparser2.lib"), package:installdir("lib"))
        end
    end)

    -- "mingw@windows" not supported temporary
    on_install("linux", "macosx", function (package)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.autoconf").install(package, confs)
    end)

    on_test(function (package)
        local confs = {}
        if package:plat() == "windows" then
            confs["defines"] = "WIN32"
            confs["cflags"] = "/c"
        end
        assert(package:check_csnippets({test = [[
            #include <stdlib.h>
            #include <time.h>
            #ifdef WIN32
                #include <windows.h>
            #endif
            #include <osipparser2/osip_port.h>
            #include <osip2/osip.h>

            static void test() {
                osip_t *p = NULL;
                int ret = osip_init(&p);
                if (ret == OSIP_SUCCESS) {
                    osip_release(p);
                    p = NULL;
                }
            }
        ]]}, { configs = confs}))
    end)
