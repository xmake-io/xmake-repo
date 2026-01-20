package("veil")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/MiroKaku/Veil")
    set_description("Windows internal undocumented API.")
    set_license("MIT")

    add_urls("https://github.com/MiroKaku/Musa.Veil/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MiroKaku/Musa.Veil.git")

    add_versions("v1.5.0", "13dfa9249c26926fc3a6b6995ff917f58bfd032c22274349c5837e1d482a3baa")
    add_versions("v1.4.1", "bf58b3d8162bb3df98d98f91ebd3b472288886e0e5e8fae058d21f85e6cc8ef3")

    add_syslinks("ntdll")

    on_install("windows", function (package)
        io.replace("Veil.h", "#pragma comment(lib, \"ntdll.lib\")", "", {plain = true})

        os.cp("Veil", package:installdir("include"))
        os.cp("veil.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("NtReadFile", {includes = "veil.h"}))
    end)
