package("tgbot-cpp")
    set_homepage("http://reo7sp.github.io/tgbot-cpp")
    set_description("C++ library for Telegram bot API")
    set_license("MIT")

    set_urls("https://github.com/reo7sp/tgbot-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/reo7sp/tgbot-cpp.git")

    add_versions("v1.7.2", "3a41c25c5e4b60bda3f278550a380f1c7c382fd50ea1ab1801edc837d1535462")

    add_configs("curl", {description = "Use curl-based http client CurlHttpClient", default = false, type = "boolean"})

    add_deps("openssl", "zlib")
    add_deps("boost", {configs = {system = true}})

    on_load(function (package)
        if package:config("curl") then
            package:add("deps", "libcurl", {configs = {openssl = true}})
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_requires("openssl", "zlib")
            add_requires("boost", {configs = {system = true}})
            if has_config("curl") then
                add_requires("libcurl", {configs = {openssl = true}})
            end
            add_rules("mode.debug", "mode.release")
            target("tgbot-cpp")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_includedirs("include")
                add_headerfiles("include/(tgbot/**.h)")
                set_languages("c++14")
                if is_plat("windows") then
                    add_defines("_WIN32_WINNT=0x0601", "WIN32_LEAN_AND_MEAN", "NOMINMAX")
                end
                if is_kind("shared") then
                    -- add_defines("TGBOT_DLL")
                    if is_plat("windows") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                end
                add_packages("boost", "openssl", "zlib")
                if has_config("curl") then
                    add_packages("libcurl")
                    add_defines("HAVE_CURL")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tgbot/tgbot.h>
            void test() {
                TgBot::Bot bot("PLACE YOUR TOKEN HERE");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
