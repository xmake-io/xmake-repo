package("dpp")
    set_homepage("https://github.com/brainboxdotcc/DPP")
    set_description("D++ Extremely Lightweight C++ Discord Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/brainboxdotcc/DPP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brainboxdotcc/DPP.git")

    add_versions("v10.0.8", "7a16d31841fc67fabcafbc33abb1a6b2ac472202df7e8c48542f77e089de08e3")
    add_patches("v10.0.8", path.join(os.scriptdir(), "patches", "v10.0.8", "dpp_dependencies.patch"), "a61b4175c65d9e1b366a08eae7ef6b2f567dc3a96e73332c39a76155c0b13e65")

    add_deps("fmt", "nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "DPP_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        configs.mode = package:debug() and "debug" or "release"
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                dpp::cluster bot(std::getenv("BOT_TOKEN"));
            
                bot.on_ready([&bot](auto event) {
                    if (dpp::run_once<struct register_bot_commands>()) {
                        bot.global_command_create(
                            dpp::slashcommand("ping", "Ping pong!", bot.me.id)
                        );
                    }
                });
            
                bot.start(false);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "dpp/dpp.h"}))
    end)
