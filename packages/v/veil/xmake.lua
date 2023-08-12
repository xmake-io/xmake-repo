package("veil")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/MiroKaku/Veil")
    set_description("Windows internal undocumented API.")
    set_license("MIT")

    add_urls("https://github.com/MiroKaku/Veil.git")
    add_versions("2023.07.19", "56464db15ebede014195ba82e2dc46d302c83798")

    on_install("windows", function (package)
        package:add("syslinks", "ntdll")
        io.replace("Veil.h", "#pragma comment(lib, \"ntdll.lib\")", "", {plain = true})

        os.cp("Veil", package:installdir("include"))
        os.cp("veil.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NtReadFile", {includes = "veil.h"}))
    end)
