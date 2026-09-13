package("keynub_licdongle")
    set_homepage("https://www.keynub.com/developers/c-cpp/")
    set_description("KeyNub USB-C license dongle SDK: the C API, the header-only C++11 wrapper and the flat companion API over the prebuilt keynub_licdongle library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/AB-KeyNub/KeyNub-SDK/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/AB-KeyNub/KeyNub-SDK.git")
    add_versions("1.1.1", "3a8242fc9a19cd6c04f1abc9e23c17374ba48712089f49c4d9f6e1830321513a")

    -- The library is prebuilt and shared; there is nothing to build here.
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_load(function (package)
        package:add("links", "keynub_licdongle", "keynub_licdongle_flat")
    end)

    on_install("windows|x64", "windows|x86", "windows|arm64",
               "linux|x86_64", "linux|arm64-v8a", "linux|aarch64",
               "macosx|x86_64", "macosx|arm64", function (package)
        local os_name = package:is_plat("windows") and "win" or (package:is_plat("linux") and "linux" or "osx")
        local arch = package:arch()
        local arch_name
        if arch == "x64" or arch == "x86_64" then
            arch_name = "x64"
        elseif arch == "x86" then
            arch_name = "x86"
        else
            arch_name = "arm64"
        end
        local natives = path.join("natives", os_name .. "-" .. arch_name)
        assert(os.isdir(natives), "no prebuilt keynub_licdongle library for %s-%s", os_name, arch_name)

        os.cp("include/licdongle.h", package:installdir("include"))
        os.cp("bindings/cpp/licdongle.hpp", package:installdir("include"))
        os.cp("bindings/flat/licd_flat.h", package:installdir("include"))
        os.cp("bindings/labview/licd_labview.h", package:installdir("include"))
        if package:is_plat("windows") then
            os.cp(path.join(natives, "keynub_licdongle.dll"), package:installdir("bin"))
            os.cp(path.join(natives, "keynub_licdongle_flat.dll"), package:installdir("bin"))
            os.cp(path.join(natives, "keynub_licdongle.lib"), package:installdir("lib"))
            os.cp(path.join(natives, "keynub_licdongle_flat.lib"), package:installdir("lib"))
        elseif package:is_plat("linux") then
            os.cp(path.join(natives, "libkeynub_licdongle.so"), package:installdir("lib"))
            os.cp(path.join(natives, "libkeynub_licdongle_flat.so"), package:installdir("lib"))
        else
            os.cp(path.join(natives, "libkeynub_licdongle.dylib"), package:installdir("lib"))
            os.cp(path.join(natives, "libkeynub_licdongle_flat.dylib"), package:installdir("lib"))
        end
        os.cp("LICENSE", package:installdir())
        os.cp("BINARY-LICENSE.txt", package:installdir())
        os.cp("NOTICE", package:installdir())
        os.cp("THIRD-PARTY-NOTICES.txt", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("licd_version", {includes = "licdongle.h"}))
        assert(package:has_cfuncs("licdf_version", {includes = "licd_flat.h"}))
    end)
