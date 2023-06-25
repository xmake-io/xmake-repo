package("discord")

    set_homepage("https://discord.com/developers/docs/game-sdk/")
    set_description("Whether you’re part of a school club, gaming group, worldwide art community, or just a handful of friends that want to spend time together, Discord makes it easy to talk every day and hang out more often.")

    add_versions("2.5.6", "426eb5fa70647d884f461c63825b63668349efb4bc68a16e70bc4a24e119b92e")
    add_versions("3.2.1", "6757bb4a1f5b42aa7b6707cbf2158420278760ac5d80d40ca708bb01d20ae6b4")

    add_patches("2.5.6", path.join(os.scriptdir(), "patches", "2.5.6", "add_include_cstdint_to_typeh.patch"), "2d36408167da601b5bb19066a951dbcac4e9783dd3b7ef8bc5ea9c3e48391d1c ")
    add_patches("3.2.1", path.join(os.scriptdir(), "patches", "3.2.1", "add_include_cstdint_to_typeh.patch"), "0ae6618dd5bf2e0149bbb3959dcd2f6df5b2a8e7295b7153eea2fd1e6d389ba0")

    set_urls("https://dl-game-sdk.discordapp.net/$(version)/discord_game_sdk.zip")

    add_configs("shared", {description = "Use shared binaries.", default = false, type = "boolean", readonly = true})
    add_configs("cppapi", {description = "Enable C++ API.", default = true, type = "boolean"})

    add_links("discordcpp")

    on_install("windows|x86", "windows|x64", "linux|x64", "macosx|x86_64", "macosx|arm64", function (package)
        if package:config("cppapi") then
            os.cp("cpp/*.h", package:installdir("include"))
        end
        os.cp("c/*.h", package:installdir("include"))
        local configs = {}
        if package:is_plat("windows") then
            if package:is_arch("x64") then
                os.cp("lib/x86_64/discord_game_sdk.dll", package:installdir("bin"))
                os.cp("lib/x86_64/discord_game_sdk.dll.lib", package:installdir("lib"))
            else
                os.cp("lib/x86/discord_game_sdk.dll", package:installdir("bin"))
                os.cp("lib/x86/discord_game_sdk.dll.lib", package:installdir("lib"))
            end
            package:add("links", "discord_game_sdk.dll")
        elseif package:is_plat("linux") then
            os.cp("lib/x86_64/discord_game_sdk.so", path.join(package:installdir("lib"), "libdiscord_game_sdk.so"))
            package:add("links", "discord_game_sdk")
        elseif package:is_plat("macosx") then
            local version = package:version()
            if ((version:major() > 3) or (version:major() == 3 and version:minor() >= 2)) and package:is_arch("arm64") then
                os.cp("lib/aarch64/discord_game_sdk.dylib", path.join(package:installdir("lib"), "libdiscord_game_sdk.dylib"))

            else
                os.cp("lib/x86_64/discord_game_sdk.dylib", path.join(package:installdir("lib"), "libdiscord_game_sdk.dylib"))
            end
            package:add("links", "discord_game_sdk")
        end

        if package:config("cppapi") then
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                discord::Core* core{};
                auto result = discord::Core::Create(310270644849737729, DiscordCreateFlags_Default, &core);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "discord.h"}))
    end)
