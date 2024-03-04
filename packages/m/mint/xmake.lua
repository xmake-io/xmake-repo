package("mint")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Chuyu-Team/MINT")
    set_description("Mouri's Internal NT API Collections")
    set_license("MIT")

    add_urls("https://github.com/Chuyu-Team/MINT/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Chuyu-Team/MINT.git")
    
    add_versions("2024.1", "3d77d9df1c724c98b6251f8c5c25cdf131143a80a226614a668d779db05d25e5")
    add_versions("2023.0","cb5a87c0af09243444a71bd04b267e0656d815cecd9512062ecd5680f6610b94")

    add_configs("namespace", {description = "use separate namespace", default = false, type = "boolean"})

    add_syslinks("ntdll")

    on_load(function (package)
        if package:config("namespace") then
            package:add("defines", "MINT_USE_SEPARATE_NAMESPACE")
        end
    end)

    on_install("windows", function (package)
        os.cp("MINT.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NtCreateProcess", {includes = "MINT.h"}))
    end)
