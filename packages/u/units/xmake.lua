package("units")

    set_homepage("https://nholthaus.github.io/units/")
    set_description("A compile-time, header-only, dimensional analysis library built on c++14 with no dependencies.")

    add_urls("https://github.com/nholthaus/units/archive/refs/tags/v2.3.3.tar.gz", "https://github.com/nholthaus/units.git")
    add_versions("v2.3.3", "b1f3c1dd11afa2710a179563845ce79f13ebf0c8c090d6aa68465b18bd8bd5fc")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("units")
                set_kind("headeronly")
                add_includedirs("include", {public = true})
                add_headerfiles("include/units.h")
        ]])

        os.cp("include/*.h", package:installdir("include"))
    end)
