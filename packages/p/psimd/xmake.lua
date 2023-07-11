package("psimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Maratyszcza/psimd")
    set_description("Portable 128-bit SIMD intrinsics")
    set_license("MIT")

    add_urls("https://github.com/Maratyszcza/psimd.git")
    add_versions("2020.5.17", "072586a71b55b7f8c584153d223e95687148a900")

    on_install("linux", "macosx", function(package)
        os.cp("include", package:installdir())
    end)

    on_test(function(package)
        assert(package:check_csnippets({test = [[
            void test() {
                const psimd_f32 log2e = psimd_splat_f32(0x1.715476p+0f);
                const psimd_f32 inf = psimd_splat_f32(__builtin_inff());
            }
        ]]}, {configs = {languages = "c11"}, includes = "psimd.h"}))
    end)
