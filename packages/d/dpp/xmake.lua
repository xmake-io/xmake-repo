package("dpp")
    set_homepage("https://github.com/brainboxdotcc/DPP")
    set_description("D++ Extremely Lightweight C++ Discord Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/brainboxdotcc/DPP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brainboxdotcc/DPP.git")
 
    -- NOTE !
    -- Keep all versions with the same major number. If D++ switch to a new major version,
    -- keep only the latest previous versions.
    -- i.e. if D++ switch to v11.x.x, keep only the latest v10.x.x and delete the rest.

    add_versions("v10.0.15", "5370e7fa3e76ed78b87dc4d9c01cc5a5f1a5789ebf1d3d0e8deff05cb665c539")
    add_patches("v10.0.15", path.join(os.scriptdir(), "patches", "v10.0.14", "static_export.patch"), "2a5d47e09438e17b67d9fd73a943653ab8d1739f118f102ed44ae8d34c19da07")

    add_versions("v10.0.14", "5eb4cf3b4f4ba200d5f0d57929a1b96cc79e2398004afccc9d9c63aee865ca9d")
    add_patches("v10.0.14", path.join(os.scriptdir(), "patches", "v10.0.10", "permission_include.patch"), "4fdf8e406c7f610453090253bf1640e42c47a06968f65a4a21d01104a2d04fd4")
    add_patches("v10.0.14", path.join(os.scriptdir(), "patches", "v10.0.13", "cstring_include.patch"), "fd3af16877d46ba572f2aa33d80d36b44892a886fb3987953ac2e5fbd14263b9")
    add_patches("v10.0.14", path.join(os.scriptdir(), "patches", "v10.0.14", "static_export.patch"), "2a5d47e09438e17b67d9fd73a943653ab8d1739f118f102ed44ae8d34c19da07")

    add_versions("v10.0.13", "35dc9f5dc265d70047df67b13ae45f7345ed3f3b842b114fd89cacb3c83428ed")
    add_patches("v10.0.13", path.join(os.scriptdir(), "patches", "v10.0.8", "static_export.patch"), "d18487580faa9af21862bcff30ddfa5d5ab5cda6aa5f779bcc1787a96ca66447")
    add_patches("v10.0.13", path.join(os.scriptdir(), "patches", "v10.0.10", "permission_include.patch"), "4fdf8e406c7f610453090253bf1640e42c47a06968f65a4a21d01104a2d04fd4")
    add_patches("v10.0.13", path.join(os.scriptdir(), "patches", "v10.0.13", "cstring_include.patch"), "fd3af16877d46ba572f2aa33d80d36b44892a886fb3987953ac2e5fbd14263b9")

    add_versions("v10.0.12", "a986fcd0e6d491b0df6522fe2c85bff1e16f5513bcc3abee1b774ff25e03ee1b")
    add_patches("v10.0.12", path.join(os.scriptdir(), "patches", "v10.0.8", "static_export.patch"), "d18487580faa9af21862bcff30ddfa5d5ab5cda6aa5f779bcc1787a96ca66447")
    add_patches("v10.0.12", path.join(os.scriptdir(), "patches", "v10.0.10", "permission_include.patch"), "4fdf8e406c7f610453090253bf1640e42c47a06968f65a4a21d01104a2d04fd4")
    add_patches("v10.0.12", path.join(os.scriptdir(), "patches", "v10.0.12", "mutex_include.patch"), "0fc8ee9d6bca65d591ce473aa1136fc30209e27746e91d4088cf3198564b715d")

    add_versions("v10.0.11", "33463292f3030eabf70ab54ff09475945b4d87a9c6e428c712015cba93a1ed96")
    add_patches("v10.0.11", path.join(os.scriptdir(), "patches", "v10.0.8", "static_export.patch"), "d18487580faa9af21862bcff30ddfa5d5ab5cda6aa5f779bcc1787a96ca66447")
    add_patches("v10.0.11", path.join(os.scriptdir(), "patches", "v10.0.10", "permission_include.patch"), "4fdf8e406c7f610453090253bf1640e42c47a06968f65a4a21d01104a2d04fd4")

    add_versions("v10.0.10", "2a1c26f606298e5b683d1e140219c434e61c4b22e8510fa2a2d5f7b6758dff95")
    add_patches("v10.0.10", path.join(os.scriptdir(), "patches", "v10.0.8", "static_export.patch"), "d18487580faa9af21862bcff30ddfa5d5ab5cda6aa5f779bcc1787a96ca66447")
    add_patches("v10.0.10", path.join(os.scriptdir(), "patches", "v10.0.10", "permission_include.patch"), "4fdf8e406c7f610453090253bf1640e42c47a06968f65a4a21d01104a2d04fd4")

    add_versions("v10.0.8", "7a16d31841fc67fabcafbc33abb1a6b2ac472202df7e8c48542f77e089de08e3")
    add_patches("v10.0.8", path.join(os.scriptdir(), "patches", "v10.0.8", "static_export.patch"), "d18487580faa9af21862bcff30ddfa5d5ab5cda6aa5f779bcc1787a96ca66447")

    add_deps("nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "DPP_STATIC")
        end

        if package:version():le("v10.0.13") then
            package:add("deps", "fmt")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        -- fix dpp dependencies
        for _, file in ipairs(table.join(os.files("include/**.h"), os.files("src/**.cpp"))) do
            io.replace(file, "#include <dpp/fmt/", "#include <fmt/", {plain = true})
            io.replace(file, "#include <dpp/nlohmann/", "#include <nlohmann/", {plain = true})
        end

	for _, file in ipairs(os.files("src/**.cpp")) do
		io.replace(file, "#include <nlohmann/json_fwd.hpp>", "#include <nlohmann/json.hpp>", {plain = true})
	end

	if package:version():le("v10.0.14") then
                os.rmdir("include/dpp/fmt")
	end
        io.replace("include/dpp/restrequest.h", "#include <nlohmann/json_fwd.hpp>", "#include <nlohmann/json.hpp>", {plain = true})
        os.rmdir("include/dpp/nlohmann")

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
