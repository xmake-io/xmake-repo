package("discord")

    set_homepage("https://discord.com/developers/docs/game-sdk/")
    set_description("Whether you’re part of a school club, gaming group, worldwide art community, or just a handful of friends that want to spend time together, Discord makes it easy to talk every day and hang out more often.")

    add_versions("2.5.6", "426eb5fa70647d884f461c63825b63668349efb4bc68a16e70bc4a24e119b92e")

    set_urls("https://dl-game-sdk.discordapp.net/$(version)/discord_game_sdk.zip")

    on_install("windows", function (package)
        os.cp("cpp/*.h", package:installdir("include"))
        os.cp("Release/*.lib", package:installdir("lib"))
        if package:is_arch("x86_64") then
            os.cp("lib/x86_64/discord_game_sdk.dll", package:installdir("bin"))
            os.cp("lib/x86_64/discord_game_sdk.dll.lib", package:installdir("lib"))
        else
            os.cp("lib/x86/discord_game_sdk.dll", package:installdir("bin"))
            os.cp("lib/x86/discord_game_sdk.dll.lib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                discord::Core* core{};
                auto result = discord::Core::Create(310270644849737729, DiscordCreateFlags_Default, &core);
            }
        ]]}, {configs = {languages = "c++14"}}, {includes = "discord.h"}))
    end)
