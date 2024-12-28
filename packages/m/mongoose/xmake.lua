package("mongoose")

    set_kind("library", {headeronly = true})
    set_homepage("https://mongoose.ws")
    set_description("Embedded Web Server")
    set_license("GPL-2.0")

    add_urls("https://github.com/cesanta/mongoose/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cesanta/mongoose.git")

    add_versions("7.16", "f2c42135f7bc34b3d10b6401e9326a20ba5dd42d4721b6a526826ba31c1679fd")
    add_versions("7.15", "efcb5aa89b85d40373dcff3241316ddc0f2f130ad7f05c9c964f8cc1e2078a0b")
    add_versions("7.14", "7c4aecf92f7f27f1cbb2cbda3c185c385f2b7af84f6bd7c0ce31b84742b15691")
    add_versions("7.13", "5c9dc8d1d1762ef483b6d2fbf5234e421ca944b722225bb533d2d0507b118a0f")
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
