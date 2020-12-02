package("brotli")

    set_homepage("https://github.com/google/brotli")
    set_description("Brotli compression format.")

    set_urls("https://github.com/google/brotli/archive/v$(version).tar.gz",
             "https://github.com/google/brotli.git")

    add_versions("1.0.9", "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46")

    -- Fix VC C++ 12.0 BROTLI_MSVC_VERSION_CHECK calls
    -- VC <= 2012 build failed
    if is_plat("windows") then
        add_patches("1.0.9", path.join(os.scriptdir(), "patches", "1.0.9", "common_platform.patch"),
                    "5d7363a6ed1f9a504dc7af08920cd184f0d04d1ad12d25d657364cf0a2dae6bb")
        add_patches("1.0.9", path.join(os.scriptdir(), "patches", "1.0.9", "tool_brotli.patch"),
                    "333e2a0306cf33f2fac381aa6b81afd3d1237e7511e5cc8fe7fb760d16d01ca1")
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