package("simsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/simsimd-faster-scipy/")
    set_description("Vector Similarity Functions 3x-200x Faster than SciPy and NumPy")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/SimSIMD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/SimSIMD.git")

    add_versions("v5.6.4", "cc337970f16cf4d3997a62165fb4ec565ca5798bc24e7d9643972fd7307ea9b6")
    add_versions("v5.6.0", "2565e7100b47fd8afd4dd9c8ec067098c9710782d1eba71155ed75930e424058")
    add_versions("v5.4.4", "bf48d4772e82efdecd3acdc88431ea03b6110754ac263be338fd3ceb172998d2")
    add_versions("v4.3.2", "0732603a0680a4b9c70abe0b59de011447ad7db0e0631c2f7c307c0135aa4d43")
    add_versions("v4.3.1", "d3c54c5b27f8bbb161c8523c47ddc98bfeb75cac17066c959f42ebe78c518b0f")
    add_versions("v3.9.0", "8e79b628ba89beebc7c4c853323db0e10ebb6f85bcda2641e1ebaf77cfbda7f9")

    if on_check then
        on_check("android", function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <arm_neon.h>
                #pragma clang attribute push( \
                    __attribute__((target("arch=armv8.2-a+dotprod"))), apply_to = function)
                int32x4_t test_simd() {
                    int32x4_t ab_vec = vdupq_n_s32(0);
                    int8x16_t a_vec = vdupq_n_s8(1);
                    int8x16_t b_vec = vdupq_n_s8(2);
                    return vdotq_s32(ab_vec, a_vec, b_vec);
                }
                #pragma clang attribute pop
            ]]}), "package(simsimd) requires a higher version of NDK.")
        end)
    end

    on_install(function (package)
        os.cp("include", package:installdir())
        if not package:has_ctypes("_Float16") then
            package:add("defines", "SIMSIMD_NATIVE_F16=0")
        end
        if not package:has_ctypes("bfloat16_t") then
            package:add("defines", "SIMSIMD_NATIVE_BF16=0")
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("simsimd/simsimd.h"))
    end)
