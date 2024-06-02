package("telebot")
    set_homepage("https://elmurod.net/telebot")
    set_description("Telegram Bot API in C")
    set_license("Apache-2.0")

    add_urls("https://github.com/smartnode/telebot.git")
    add_versions("2024.05.11", "63693b4f9bcdc3fd0b0f2b37104b6694d723b5b4")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("json-c", "libcurl")
    if is_plat("windows", "mingw@macosx,linux") then
        add_deps("pthreads4w")
    end

    on_install("windows|x64", "windows|x86", "mingw@macosx,linux", "linux", function (package)
        if package:is_plat("windows") then
            io.replace("src/telebot.c", "#include <unistd.h>", "", {plain = true})
            io.replace("src/telebot-core.c", "#include <unistd.h>", "", {plain = true})
        end

        io.replace("src/telebot.c", "#include <json.h>", "#include <json-c/json.h>", {plain = true})
        io.replace("src/telebot-core.c", "#include <json.h>", "#include <json-c/json.h>", {plain = true})
        io.replace("src/telebot-parser.c", "#include <json.h>", "#include <json-c/json.h>", {plain = true})

        io.replace("src/telebot.c", "#include <json_object.h>", "#include <json-c/json_object.h>", {plain = true})
        io.replace("src/telebot-parser.c", "#include <json_object.h>", "#include <json-c/json_object.h>", {plain = true})

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_encodings("utf-8")
            if is_plat("windows", "mingw@macosx,linux") then
                add_requires("pthreads4w")
                add_packages("pthreads4w")
            end
            add_requires("json-c", "libcurl")
            add_packages("json-c", "libcurl")
            target("telebot")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("include/*.h")
                add_includedirs("include")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("telebot_create", {includes = "telebot.h"}))
    end)
