package("picolibc")
    set_homepage("https://keithp.com/picolibc")
    set_description("a micro C library for embedded soc")

    local version_map = {
        ["1.8.10"] = "1.8.10-14.2.rel1"
    }

    set_urls(
        "https://keithp.com/picolibc/dist/gnu-arm-embedded/picolibc-$(version).zip", {version = function (version)
            return version_map[tostring(version)]
        end})
    add_versions("1.8.10", "a5d0e5be0cd5e7b0e47a229a49f58d9b258a7012c3402751711d71415a645f99")

    on_install(function(package)
        os.cp("*|manifest.txt", package:installdir())
    end)
