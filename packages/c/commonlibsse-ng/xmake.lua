package("commonlibsse-ng")
    set_homepage("https://github.com/CharmedBaryon/CommonLibSSE-NG")
    set_description("A reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    add_urls("https://github.com/CharmedBaryon/CommonLibSSE-NG/archive/$(version).zip",
             "https://github.com/CharmedBaryon/CommonLibSSE-NG.git")
    add_versions("v3.7.0", "c2fc2b5ac1c67ad4779bd0570c95fe494e0724f957a61880fa42cf74d1edce14")
    add_versions("v3.6.0", "6f84c36f5747cff73d6a95bc7b9de84b11601648b218fd3e69edc884cc94a5a8")
    add_versions("v3.5.6", "a3e1d4ec7496adca8310613fe75a2e08a9dbf562a9febec584b4e79aacc92bd3")
    add_versions("v3.5.5", "5b00de66b9b8bc300244f14f1a281f26961931ba28ed0f4c9cce3a30a77c784a")

    add_configs("skyrim_se", {description = "Enable runtime support for Skyrim SE", default = true, type = "boolean"})
    add_configs("skyrim_ae", {description = "Enable runtime support for Skyrim AE", default = true, type = "boolean"})
    add_configs("skyrim_vr", {description = "Enable runtime support for Skyrim VR", default = true, type = "boolean"})
    add_configs("skse_xbyak", {description = "Enable trampoline support for Xbyak", default = false, type = "boolean"})

    add_deps("fmt", "rapidcsv")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    add_syslinks("version", "user32", "shell32", "ole32", "advapi32")

    on_load("windows|x64", function(package)
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

    on_install("windows|x64", function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {}
        configs.skyrim_se = package:config("skyrim_se")
        configs.skyrim_ae = package:config("skyrim_ae")
        configs.skyrim_vr = package:config("skyrim_vr")
        configs.skse_xbyak = package:config("skse_xbyak")

        import("package.tools.xmake").install(package, configs)
    end)

    on_test("windows|x64", function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <SKSE/SKSE.h>

            SKSEPluginLoad(const SKSE::LoadInterface*) {
                return true;
            };
        ]]}, { configs = { languages = "c++20" } }))
    end)
