package("mongoose")

    set_kind("library", {headeronly = true})
    set_homepage("https://mongoose.ws")
    set_description("Embedded Web Server")
    set_license("GPL-2.0")

    add_urls("https://github.com/cesanta/mongoose/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cesanta/mongoose.git")

    add_versions("7.11", "cb2a746505827d3225abdb1c8d508950aa3d769abb0cda59065b1628608efb2e")

    add_configs("ssl", {description = "Enable SSL", default = nil, type = "string", values = {"openssl", "mbedtls"}})

    on_load(function (package)
        if package:config("ssl") == "openssl" then
            package:add("deps", "openssl")
            package:add("defines", "MG_ENABLE_OPENSSL=1")
        elseif package:config("ssl") == "mbedtls" then
            package:add("deps", "mbedtls")
            package:add("defines", "MG_ENABLE_MBEDTLS=1")
        end
    end)

    on_install(function (package)
        -- Let users custom build because there are too many build options
        -- https://mongoose.ws/documentation/#build-options
        os.cp("mongoose.c", package:installdir("include"))
        os.cp("mongoose.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include "mongoose.c"
            void test() {
                struct mg_mgr mgr;
                mg_mgr_init(&mgr);
            }
        ]]}))
    end)
