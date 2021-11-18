package("openh264")

    set_homepage("http://www.openh264.org/")
    set_description("OpenH264 is a codec library which supports H.264 encoding and decoding.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/cisco/openh264/archive/refs/tags/$(version).tar.gz")
    add_versions("v2.1.1", "af173e90fce65f80722fa894e1af0d6b07572292e76de7b65273df4c0a8be678")

    add_deps("meson", "ninja", "nasm")
    if is_plat("linux") then
        add_syslinks("pthread", "rt")
    end
    on_install("windows", "linux", function (package)
        import("package.tools.meson").build(package, {"-Dtests=disabled"}, {buildir = "out"})
        import("package.tools.ninja").install(package, {}, {buildir = "out"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "libopenh264.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "libopenh264.so*"))
            os.tryrm(path.join(package:installdir("lib"), "openh264.lib"))
            os.tryrm(path.join(package:installdir("bin"), "openh264-*.dll"))
        end
        if package:is_plat("windows") then
            os.trymv(path.join(package:installdir("lib"), "libopenh264.a"), path.join(package:installdir("lib"), "openh264.lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("WelsGetCodecVersion", {includes = "wels/codec_api.h"}))
    end)
