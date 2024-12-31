package("cinatra")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/cinatra")
    set_description("modern c++(c++20), cross-platform, header-only, easy to use http framework")
    set_license("MIT")

    add_urls("https://github.com/qicosmos/cinatra/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qicosmos/cinatra.git")

    add_versions("0.9.4", "2b8b4e264f8083674554db55ca137998f02c528730cf9565697234fec9de3378")
    add_versions("0.9.1", "d1a8018e41caabbda2c380175b632e3c9c10b519727f6b998eda4e3f4ede84bd")
    add_versions("v0.8.9", "007dc38aceedf42d03a9c05dc9aa6d2f303456ae7ce1100800df7a565b83b510")
    add_versions("v0.8.0", "4e14d5206408eccb43b3e810d3a1fe228fbc7496ded8a16b041ed12cbcce4479")

    add_patches(">=0.8.9 <=0.9.2", "patches/0.8.9/windows-move.patch", "c913ed0e9044ffc0ced40516245ec0d55262f8eabd30244d9911c3f0427a60f5")

    add_configs("ssl", {description = "Enable SSL", default = false, type = "boolean"})
    add_configs("gzip", {description = "Enable GZIP", default = false, type = "boolean"})
    add_configs("sse42", {description = "Enable sse4.2 instruction set", default = false, type = "boolean"})
    add_configs("avx2", {description = "Enable avx2 instruction set", default = false, type = "boolean"})
    add_configs("aarch64", {description = "Enable aarch64 instruction set (only arm)", default = false, type = "boolean"})

    add_deps("asio")
    add_deps("async_simple", {configs = {aio = false}})

    on_check("windows", function (package)
        local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
        if vs_toolset then
            local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
            local minor = vs_toolset_ver:minor()
            assert(minor and minor >= 30, "package(cinatra) require vs_toolset >= 14.3")
        end
    end)

    on_load(function (package)
        package:add("defines", "ASIO_STANDALONE")
        if package:config("ssl") then
            package:add("deps", "openssl")
            package:add("defines", "CINATRA_ENABLE_SSL")
        end
        if package:config("gzip") then
            package:add("deps", "zlib")
            package:add("defines", "CINATRA_ENABLE_GZIP")
        end

        local configdeps = {
            sse42 = "CINATRA_SSE",
            avx2 = "CINATRA_AVX2",
            aarch64 = "CINATRA_ARM_OPT"
        }
        
        for name, item in pairs(configdeps) do
            if package:config(name) then
                package:add("defines", item)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("cinatra.hpp", {configs = {languages = "c++20"}}))
    end)
