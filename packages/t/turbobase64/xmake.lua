package("turbobase64")

    set_homepage("https://github.com/powturbo/Turbo-Base64")
    set_description("Turbo Base64 - Fastest Base64 SIMD/Neon/Altivec")
    set_license("GPL-3.0")

    add_urls("https://github.com/powturbo/Turbo-Base64.git")
    add_versions("2022.02.21", "cf6e4f2f7fbe7fc5fe780fdf1cc4d1aa609fc46e")

    -- CMake build support and patch is from https://github.com/powturbo/Turbo-Base64/pull/14
    add_patches("2022.02.21", path.join(os.scriptdir(), "patches", "2022.02.21", "header.patch"), "0458a4eaf2b4f5429fcd7755ad8637240cb05081d2ab0531e41ed52ef1e8a477")

    add_configs("ncheck", {description = "Dinsable for checking for more fast decoding", default = false, type = "boolean"})
    add_configs("fullcheck", {description = "Enable full base64 checking", default = false, type = "boolean"})
    add_configs("avx512", {description = "Enable AVX512", default = false, type = "boolean"})

    add_deps("cmake")

    on_install("linux", "macos", "windows", function (package)
        os.cp(path.join(package:scriptdir(), "port/*"), ".")

        local configs = {
            "-DBUILD_TESTS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DNCHECK=" .. (package:config("nocheck") and "ON" or "OFF"))
        table.insert(configs, "-DFULLCHECK=" .. (package:config("fullcheck") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_AVX512=" .. (package:config("avx512") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tb64ini", {includes = "turbobase64/turbob64.h"}))
    end)

