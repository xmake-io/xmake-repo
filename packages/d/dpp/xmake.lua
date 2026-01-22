package("dpp")
    set_homepage("https://github.com/brainboxdotcc/DPP")
    set_description("D++ Extremely Lightweight C++ Discord Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/brainboxdotcc/DPP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brainboxdotcc/DPP.git")

    add_versions("v10.1.4", "f11b6d3fc5cc8febcf672b573ca74293ead6c6ea48a66ac0316ab9a5cbd09441")
    add_versions("v10.0.31", "3e392868c0dc3d0f13a00cfa190a925a20bde62bea58fd87d4acf14de11062bf")
    add_versions("v10.0.30", "fb7019770bd5c5f0539523536250da387ee1fa9c92e59c0bcff6c9adaf3d77e8")
    add_versions("v10.0.29", "a37e91fbdabee20cb0313700588db4077abf0ebabafe386457d999d22d2d0682")
    add_versions("v10.0.28", "aa0c16a1583f649f28ec7739c941e9f2bf9c891c0b87ef8278420618f8bacd46")
    add_versions("v10.0.27", "525a5c10a5fdd69996f48826ea1c37a3f08ba934c95e4cb9738afd209a2ecdb7")
    add_versions("v10.0.26", "038e95c3ef8228957bf2a84d4ff73ca1dd95ecb2cf7478ca57137d5d99f7e709")
    add_versions("v10.0.25", "bd39d24e01748ff4cc34ad7ca0faaa0f53542efd8843d4bcc75566a11f0f248b")
    add_versions("v10.0.24", "e5d561b864a7397caeb5616d388ebbd79a8f21077f3b13ac6ccd7e29c746daa9")
    add_versions("v10.0.23", "8f9db61c3586a492ada378235300c509e3bc2fc090cef32de0a8241741038df0")
    add_versions("v10.0.22", "f8da36a9e24012fdff55a988e41d2015235b9e564b3151a1e5158fa1c7e05648")
    add_versions("v10.0.21", "8ef2bb75f16b80d742a99c3a18ab5a2a57bce74238518af9b9aca670c2d7034b")
    add_versions("v10.0.20", "c4a7481c714c27d9c1411c668212e433fa5f6631a933676269c866295bd4ef73")
    add_versions("v10.0.19", "1126d927540715f7405d5bc33bd7ae54314431c7b1545bb5e886addfc547cf51")
    add_versions("v10.0.18", "0d976673852a5d8e71833d5f6a5b9767ffaf6b6a053d8420fa921adfcb80ab64")
    add_versions("v10.0.17", "7596dcc5602f756709f57d38c7f5b4c743cedb3d808416011ef0ab279cd5391e")
    add_versions("v10.0.16", "dc99af06d9c2fdeefde534d99c00cbda4c96bac7d02ee68bcbbc2b47848bb28e")

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

    add_deps("nlohmann_json", "openssl", "zlib")

    add_configs("voice", { description = "Enable voice support for the library.", default = true, type = "boolean" , readonly = false})
    add_configs("have_voice", { description = "Enable voice support for the library (Deprecated flag, move out to newer version 'voice').", default = false, type = "boolean" , readonly = false})
    add_configs("coro", { description = "Enable experimental coroutines support for the library.", default = false, type = "boolean" , readonly = false})

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "DPP_STATIC")
        end
        if package:config("have_voice") then
            wprint([[
                === Deprecation Warning ===
                You should move out to use voice flag, instead of have_voice
                Deprecated:
                add_requires("dpp", {
                    configs = {have_voice = true}
                })
                New (Recommended):
                add_requires("dpp", {
                    configs = {voice = true}
                })
                This flag will be removed soon, please migrate ASAP!
            ]])
        end
        if package:config("voice") then
            package:add("defines", "HAVE_VOICE")
            package:add("deps", "libsodium", "libopus")
        end

        if package:config("coro") then
            package:add("defines", "DPP_CORO")
        end

        if package:version():le("v10.0.13") then
            package:add("deps", "fmt")
        end

        if package:version():ge("v10.0.23") then
            package:add("defines", "DPP_USE_EXTERNAL_JSON")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        -- fix dpp dependencies
        for _, file in ipairs(table.join(os.files("include/**.h"), os.files("src/**.cpp"))) do
            io.replace(file, "#include <dpp/fmt/", "#include <fmt/", {plain = true})

            if package:version():lt("v10.0.23") then
                io.replace(file, "#include <dpp/nlohmann/", "#include <nlohmann/", {plain = true})
            end
        end

        for _, file in ipairs(os.files("src/**.cpp")) do
            io.replace(file, "#include <nlohmann/json_fwd.hpp>", "#include <nlohmann/json.hpp>", {plain = true})
        end

        if package:version():le("v10.0.14") then
            os.rmdir("include/dpp/fmt")
        end
        
        io.replace("include/dpp/restrequest.h", "#include <nlohmann/json_fwd.hpp>", "#include <nlohmann/json.hpp>", {plain = true})
        os.rmdir("include/dpp/nlohmann")

        local configs = {
            voice = package:config("voice") or package:config("have_voice"),
            coro = package:config("coro")
        }
        
        if package:version():ge("v10.0.29") and package:is_plat("windows") then
            configs.cxflags = "/bigobj /Gy"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        local test_cpp_ver = "c++17"
        if package:config("coro") then
            test_cpp_ver = "c++20"
        end
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
        ]]}, {configs = {languages = test_cpp_ver}, includes = "dpp/dpp.h"}))
    end)
