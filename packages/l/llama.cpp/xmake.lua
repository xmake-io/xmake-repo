package("llama.cpp")
    set_homepage("https://github.com/ggerganov/llama.cpp")
    set_description("Port of Facebook's LLaMA model in C/C++")

    add_urls("https://github.com/ggerganov/llama.cpp.git")
    add_versions("2023.03.11", "7d9ed7b25fe17db3fc8848b5116d14682864ce8e")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("llama")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("(*.h)")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ggml_time_us", {includes = "ggml.h"}))
    end)
