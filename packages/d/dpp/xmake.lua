package("dpp")
    set_homepage("https://github.com/brainboxdotcc/DPP")
    set_description("D++ Extremely Lightweight C++ Discord Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/brainboxdotcc/DPP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brainboxdotcc/DPP.git")

    add_versions("v10.0.8", "7a16d31841fc67fabcafbc33abb1a6b2ac472202df7e8c48542f77e089de08e3")
    add_patches("v10.0.8", path.join(os.scriptdir(), "patches", "v10.0.8", "dpp_dependencies.patch"), "0d48824f8029ea7fed89327e61513d6e10b44110e50d577e7023fd756ac787db")

    add_deps("fmt", "nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "DPP_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
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
