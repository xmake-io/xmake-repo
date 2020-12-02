package("brotli")

    set_homepage("https://github.com/google/brotli")
    set_description("Brotli compression format.")

    set_urls("https://github.com/google/brotli/archive/v$(version).tar.gz",
             "https://github.com/google/brotli.git")

    add_versions("1.0.9", "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46")

    add_deps("cmake")

    on_load("linux", function (package)
        if package:config("shared") then
            package:add("links", "brotlidec", "brotlienc", "brotlicommon")
        else
            package:add("links", "brotlidec-static", "brotlienc-static", "brotlicommon-static")
        end
    end)

    on_install("linux", "macosx", "windows", function(package)
        local configs = {"-DBUILD_TESTING=OFF"}
        -- NOTE: BUILD_SHARED_LIBS not supported now, may be added in future.
        -- table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs, {buildir = "builddir"})
        os.cp("builddir/install/bin", package:installdir())
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*-static.*"))
        else
            for _, name in ipairs({"brotlicommon", "brotlienc", "brotlidec"}) do
                os.rm(path.join(package:installdir("lib"), "*" .. name .. ".*"))
                os.rm(path.join(package:installdir("bin"), name .. ".dll"))
            end
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        os.vrun("brotli --version")
        assert(package:check_csnippets([[
            void test() {
                BrotliEncoderState* s = BrotliEncoderCreateInstance(NULL, NULL, NULL);
                BrotliEncoderDestroyInstance(s);
            }
        ]], {includes = "brotli/encode.h"}))
    end)
