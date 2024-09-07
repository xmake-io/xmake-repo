package("libmspack")
    set_homepage("https://www.cabextract.org.uk/libmspack/")
    set_description("libmspack is a portable library for some loosely related Microsoft compression formats.")
    set_license("LGPL-2.0")

    add_urls("https://github.com/kyz/libmspack/archive/refs/tags/$(version).zip",
             "https://github.com/kyz/libmspack.git")

    add_versions("v1.11", "88f8395ff4630d600a0973d7c8c011c21877b80439be5d6cc840afd02f54da20")
    add_versions("v0.10.1alpha", "d51e3b0d42afef91939fb282f7712e0b81c243ffe0aaacafc977d384408b4ab1")

    on_install(function (package)
        os.cd("libmspack/mspack")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("mspack")
                set_kind("$(kind)")
                add_defines("HAVE_INTTYPES_H=1")
                add_files("*.c|debug.c")
                add_includedirs(".")
                add_headerfiles("mspack.h")
                if is_plat("windows", "mingw") and is_kind("shared") then
                    add_files("mspack.def")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mspack_create_chm_decompressor", {includes = "mspack.h"}))
    end)
