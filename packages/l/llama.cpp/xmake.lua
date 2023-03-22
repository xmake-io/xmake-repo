package("llama.cpp")
    set_homepage("https://github.com/ggerganov/llama.cpp")
    set_description("Port of Facebook's LLaMA model in C/C++")

    add_urls("https://github.com/ggerganov/llama.cpp.git")
    add_versions("2023.03.11", "7d9ed7b25fe17db3fc8848b5116d14682864ce8e")

    if is_plat("macosx") then
        add_frameworks("Accelerate")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("linux", "macosx", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("llama")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("(*.h)")
                set_languages("c11")
                add_cflags("-pthread")
                if is_plat("macosx") then
                    add_defines("GGML_USE_ACCELERATE")
                    add_frameworks("Accelerate")
                end
                if is_arch("x86_64", "x64", "i386", "x86") then
                    add_vectorexts("avx", "avx2", "sse3")
                    add_cflags("-mf16c")
                elseif is_arch("arm.*") then
                    add_vectorexts("neon")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ggml_time_us", {includes = "ggml.h"}))
    end)
