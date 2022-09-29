package("commonlibsse-ng")
    set_homepage("https://github.com/CharmedBaryon/CommonLibSSE-NG")
    set_description("A reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    add_urls("https://github.com/CharmedBaryon/CommonLibSSE-NG/archive/$(version).zip",
             "https://github.com/CharmedBaryon/CommonLibSSE-NG.git")
    add_versions("v3.5.6", "a3e1d4ec7496adca8310613fe75a2e08a9dbf562a9febec584b4e79aacc92bd3")
    add_versions("v3.5.5", "5b00de66b9b8bc300244f14f1a281f26961931ba28ed0f4c9cce3a30a77c784a")

    add_configs("skyrim_se", {description = "Enable runtime support for Skyrim SE", default = true, type = "boolean"})
    add_configs("skyrim_ae", {description = "Enable runtime support for Skyrim AE", default = true, type = "boolean"})
    add_configs("skyrim_vr", {description = "Enable runtime support for Skyrim VR", default = true, type = "boolean"})
    add_configs("skse_xbyak", {description = "Enable trampoline support for Xbyak", default = false, type = "boolean"})

    add_deps("fmt", "rapidcsv", "spdlog")

    add_syslinks("version", "user32", "shell32", "ole32", "advapi32")

    on_load(function(package)
        if package:config("skyrim_se") then
            package:add("defines", "ENABLE_SKYRIM_SE=1")
        end
        if package:config("skyrim_ae") then
            package:add("defines", "ENABLE_SKYRIM_AE=1")
        end
        if package:config("skyrim_vr") then
            package:add("defines", "ENABLE_SKYRIM_VR=1")
        end
        if package:config("skse_xbyak") then
            package:add("defines", "SKSE_SUPPORT_XBYAK=1")
            package:add("deps", "xbyak")
        end

        package:add("defines", "HAS_SKYRIM_MULTI_TARGETING=1")
    end)

    on_install(function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {}
        configs.skyrim_se = package:config("skyrim_se")
        configs.skyrim_ae = package:config("skyrim_ae")
        configs.skyrim_vr = package:config("skyrim_vr")
        configs.skse_xbyak = package:config("skse_xbyak")

        import("package.tools.xmake").install(package, configs)
    end)
