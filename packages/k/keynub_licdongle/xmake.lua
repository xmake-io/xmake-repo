package("keynub_licdongle")
    set_homepage("https://www.keynub.com/developers/c-cpp/")
    set_description("KeyNub USB-C license dongle SDK: the C API, the header-only C++11 wrapper and the flat companion API over the prebuilt keynub_licdongle library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/AB-KeyNub/KeyNub-SDK/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/AB-KeyNub/KeyNub-SDK.git")
    add_versions("1.1.1", "3a8242fc9a19cd6c04f1abc9e23c17374ba48712089f49c4d9f6e1830321513a")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_load(function (package)
        package:add("links", "keynub_licdongle", "keynub_licdongle_flat")
    end)

    on_install("windows", "linux", "macosx", function (package)
        local os_name = package:is_plat("windows") and "win" or (package:is_plat("linux") and "linux" or "osx")
        local arch_name
        if package:is_arch("x64") then
            arch_name = "x64"
        elseif package:is_arch("x86", "i386") then
            arch_name = "x86"
        else
            arch_name = "arm64"
        end
        local natives = path.join("natives", os_name .. "-" .. arch_name)
        os.cp("include/licdongle.h", package:installdir("include"))
        os.cp("bindings/cpp/licdongle.hpp", package:installdir("include"))
        os.cp("bindings/flat/licd_flat.h", package:installdir("include"))
        os.cp("bindings/labview/licd_labview.h", package:installdir("include"))
        if package:is_plat("windows") then
            os.cp(path.join(natives, "*.dll"), package:installdir("bin"))
            os.cp(path.join(natives, "*.lib"), package:installdir("lib"))
        elseif package:is_plat("linux") then
            os.cp(path.join(natives, "*.so"), package:installdir("lib"))
        else
            os.cp(path.join(natives, "*.dylib"), package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("licd_version", {includes = "licdongle.h"}))
        assert(package:has_cfuncs("licdf_version", {includes = "licd_flat.h"}))
    end)
