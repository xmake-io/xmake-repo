package("opencore-amr")
    set_homepage("https://opencore-amr.sourceforge.io")
    set_description("Library of OpenCORE Framework implementation of Adaptive Multi Rate Narrowband and Wideband (AMR-NB and AMR-WB) speech codec.")

    add_urls("https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-$(version).tar.gz")

    add_versions("0.1.6", "483eb4061088e2b34b358e47540b5d495a96cd468e361050fae615b1809dc4a1")

    add_deps("autoconf", "automake", "libtool")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Decoder_Interface_init", {includes = "opencore-amrnb/interf_dec.h"}))
        assert(package:has_cfuncs("Encoder_Interface_init", {includes = "opencore-amrnb/interf_enc.h"}))
        assert(package:has_cfuncs("D_IF_init", {includes = "opencore-amrwb/dec_if.h"}))
    end)
