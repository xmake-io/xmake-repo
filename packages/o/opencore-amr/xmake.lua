package("opencore-amr")
    set_homepage("https://opencore-amr.sourceforge.io")
    set_description("Library of OpenCORE Framework implementation of Adaptive Multi Rate Narrowband and Wideband (AMR-NB and AMR-WB) speech codec.")

    add_urls("https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-$(version).tar.gz")

    add_versions("0.1.6", "483eb4061088e2b34b358e47540b5d495a96cd468e361050fae615b1809dc4a1")

    add_deps("autoconf", "automake", "libtool")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end

        if is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local cxflags =  ndk:get("cxflags")
            local cflags = table.join(table.wrap(cxflags), ndk:get("cflags"))
            local cxxflags = table.join(table.wrap(cxflags), ndk:get("cxxflags"))
            local sysincludedirs = ndk:get("sysincludedirs")

            for _, includedir in ipairs(sysincludedirs) do
                table.insert(cflags, "-I" .. includedir)
                table.insert(cxxflags, "-I" .. includedir)
            end

            local cc = package:tool("cc")
            local cxx = package:tool("cxx")
            local cpp = package:tool("cpp")
            local as = package:tool("as")
            local ar = package:tool("ar")

            import("package.tools.autoconf").install(package, configs, {
                envs = {
                    CC = cc, CXX = cxx, CPP = cpp,
                    AR = ar, AS = as,
                    CFLAGS = table.concat(cflags, ' '),
                    CXXFLAGS = table.concat(cxxflags, ' '),
                }
            })
        else
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Decoder_Interface_init", {includes = "opencore-amrnb/interf_dec.h"}))
        assert(package:has_cfuncs("Encoder_Interface_init", {includes = "opencore-amrnb/interf_enc.h"}))
        assert(package:has_cfuncs("D_IF_init", {includes = "opencore-amrwb/dec_if.h"}))
    end)
