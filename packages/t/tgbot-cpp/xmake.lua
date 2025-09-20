package("tgbot-cpp")
    set_homepage("http://reo7sp.github.io/tgbot-cpp")
    set_description("C++ library for Telegram bot API")
    set_license("MIT")

    set_urls("https://github.com/reo7sp/tgbot-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/reo7sp/tgbot-cpp.git")

    add_versions("v1.9.1", "632aa24722e0744280f6c20ebe458a5fd47cba5d8221f4530f395639937c108c")
    add_versions("v1.9", "3aacb7cc7a4e95f9915d86794cffb0ec3128f37401a18719c1be215fca37bacb")
    add_versions("v1.8", "43ff1a359b8db026e58e517703e616accaae33e01ebc7e87613632b7e4653467")
    add_versions("v1.7.3", "f1d2863a7ac77f2a58b3c6f8a163b4d6e9d191ab5bff0dcf6e271adabf9111a9")
    add_versions("v1.7.2", "3a41c25c5e4b60bda3f278550a380f1c7c382fd50ea1ab1801edc837d1535462")

    add_configs("curl", {description = "Use curl-based http client CurlHttpClient", default = false, type = "boolean"})

    add_deps("openssl", "zlib")
    add_deps("boost", {configs = {system = true, container = true, asio = true}})

    on_load(function (package)
        if package:config("curl") then
            package:add("deps", "libcurl", {configs = {openssl = true}})
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
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
                set_languages("c++17")
                set_exceptions("cxx")
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
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tgbot/tgbot.h>
            void test() {
                TgBot::Bot bot("PLACE YOUR TOKEN HERE");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
