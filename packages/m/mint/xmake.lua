package("mint")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Chuyu-Team/MINT")
    set_description("Argh! A minimalist argument handler.")
    set_license("MIT")

    add_urls("https://github.com/Chuyu-Team/MINT/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Chuyu-Team/MINT.git")
    
    add_versions("2023.0","cb5a87c0af09243444a71bd04b267e0656d815cecd9512062ecd5680f6610b94")

    add_configs("namespace", {description = "use separate namespace", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("namespace") then
            package:add("defines", "MINT_USE_SEPARATE_NAMESPACE")
        end
    end)

    on_install("windows", function (package)
        os.cp("MINT.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("MINT.h"))
    end)
