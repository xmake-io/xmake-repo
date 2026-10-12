package("libopusenc")
    set_homepage("https://opus-codec.org")
    set_description("Modern audio compression for the internet.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiph/libopusenc/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_urls("https://github.com/xiph/opus.git", {alias = "git"})
    add_urls("https://downloads.xiph.org/releases/opus/libopusenc-$(version).tar.gz", {alias = "home"})

    add_versions("github:v0.3", "5637474cdf4ff693977fe74039049349fef7b65e3a94ad8bde51ecfcd1e94a8e")
    add_versions("home:0.3", "f616d3aff9b2034547894ccb8ab56c36cf1a4acb0d922c5d7119f97bbe58642c")
    add_versions("git:0.3", "v0.3")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libopusenc")
    elseif is_plat("linux") then
        add_extsources("pacman::libopusenc", "apt::libopusenc-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libopusenc")
    end

    add_deps("libopus")

    on_install(function (package)
        io.replace("include/opusenc.h", "#include <opus.h>", "#include <opus/opus.h>", {plain = true})
        io.replace("src/opus_header.h", "#include <opus.h>", "#include <opus/opus.h>", {plain = true})
        io.replace("src/picture.h", "#include <opus.h>", "#include <opus/opus.h>", {plain = true})
        io.replace("src/opus_header.h", "#include <opus_multistream.h>", "#include <opus/opus_multistream.h>", {plain = true})
        io.replace("src/opus_header.h", "#include <opus_projection.h>", "#include <opus/opus_projection.h>", {plain = true})

        io.writefile("xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            add_requires("libopus")
            target("libopusenc")
                set_kind("$(kind)")
                add_headerfiles("include/*.h", {prefixdir = "opus"})
                add_files("src/*.c")
                add_includedirs("include", "src")
                add_packages("libopus")
                add_defines("RANDOM_PREFIX=libopusenc", "OUTSIDE_SPEEX", "OPE_BUILD", "RESAMPLE_FULL_SINC_TABLE")
                add_defines("PACKAGE_NAME=\"libopusenc\"", "PACKAGE_VERSION=\"%s\"")
                add_rules("utils.install.cmake_importfiles")
                add_rules("utils.install.pkgconfig_importfiles")
                if is_plat("windows", "mingw") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]], package:version():shortstr()))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ope_encoder_create_file", {includes = "opus/opusenc.h"}))
    end)
