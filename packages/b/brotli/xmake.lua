package("brotli")

    set_homepage("https://github.com/google/brotli")
    set_description("Brotli compression format.")

    set_urls("https://github.com/google/brotli/archive/v$(version).tar.gz",
             "https://github.com/google/brotli.git")

    add_versions("1.0.9", "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46")

    --Fix VC C++ 12.0 BROTLI_MSVC_VERSION_CHECK calls
    --VC <= 2012 build failed
    if is_plat("windows") then
        add_patches("1.0.9", path.join(os.scriptdir(), "patches", "1.0.9_common_platform.patch"),
                    "b65bf30ffb3753ac58bf09265e57ea3ca349a1212e4c9adfad920e3b4d74df57")
        add_patches("1.0.9", path.join(os.scriptdir(), "patches", "1.0.9_tool_brotli.patch"),
                    "a9bf60127b568635c4e4bf830768f8b773a1554a86f857540265439cf3def11a")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("brotli")
                set_kind("$(kind)")
                add_includedirs("c/include", {public = true})
                add_files("c/common/*.c", "c/dec/*.c", "c/enc/*.c")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("BROTLI_SHARED_COMPILATION",
                                "BROTLICOMMON_SHARED_COMPILATION",
                                "BROTLIENC_SHARED_COMPILATION",
                                "BROTLIDEC_SHARED_COMPILATION")
                end
                add_headerfiles("c/include/(brotli/*.h)")
            target("brotlibin")
                set_kind("binary")
                add_files("c/tools/brotli.c")
                add_deps("brotli")
        ]])
        local configs = {buildir = "xbuild"}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        if package:is_plat(os.host()) then
            os.vrun("brotlibin --version")
        end
        assert(package:check_csnippets([[
            void test() {
                BrotliEncoderState* s = BrotliEncoderCreateInstance(NULL, NULL, NULL);
                BrotliEncoderDestroyInstance(s);
            }
        ]], {includes = "brotli/encode.h"}))
    end)