package("openh264")
    set_homepage("http://www.openh264.org/")
    set_description("OpenH264 is a codec library which supports H.264 encoding and decoding.")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/cisco/openh264/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cisco/openh264.git")

    add_versions("v2.5.0", "94c8ca364db990047ec4ec3481b04ce0d791e62561ef5601443011bdc00825e3")
    add_versions("v2.4.1", "8ffbe944e74043d0d3fb53d4a2a14c94de71f58dbea6a06d0dc92369542958ea")
    add_versions("v2.1.1", "af173e90fce65f80722fa894e1af0d6b07572292e76de7b65273df4c0a8be678")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt")
    end

    add_deps("meson", "ninja", "nasm")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(openh264) require ndk version > 22")
        end)
    end

    on_load("windows", function (package)
        if package:is_arch("arm.*") and (not package:is_precompiled()) then
            package:add("deps", "strawberry-perl")
        end
    end)

    on_install("!bsd and !wasm", function (package)
        io.replace("meson.build", "-Werror", "", {plain = true})

        if package:gitref() or package:version():ge("2.4.1") then
            import("package.tools.meson")

            local opt = {}
            opt.envs = meson.buildenvs(package)
            -- add gas-preprocessor to PATH
            if package:is_plat("windows") and package:is_arch("arm.*") then
                opt.envs.PATH = path.join(os.programdir(), "scripts") .. path.envsep() .. opt.envs.PATH
            end

            local configs = {"-Dtests=disabled"}
            table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
            meson.install(package, configs, opt)
        else
            import("package.tools.meson").build(package, {"-Dtests=disabled"}, {buildir = "out"})
            import("package.tools.ninja").install(package, {}, {buildir = "out"})
            if package:config("shared") then
                os.tryrm(path.join(package:installdir("lib"), "libopenh264.a"))
            else
                os.tryrm(path.join(package:installdir("lib"), "libopenh264.so*"))
                os.tryrm(path.join(package:installdir("lib"), "libopenh264.dylib"))
                os.tryrm(path.join(package:installdir("lib"), "openh264.lib"))
                os.tryrm(path.join(package:installdir("bin"), "openh264-*.dll"))
            end
            if package:is_plat("windows") then
                os.trymv(path.join(package:installdir("lib"), "libopenh264.a"), path.join(package:installdir("lib"), "openh264.lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("WelsGetCodecVersion", {includes = "wels/codec_api.h"}))
    end)
