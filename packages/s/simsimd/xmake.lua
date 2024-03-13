package("simsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/simsimd-faster-scipy/")
    set_description("Vector Similarity Functions 3x-200x Faster than SciPy and NumPy — for Python, JavaScript, Rust, and C 11, supporting f64, f32, f16, i8, and binary vectors using SIMD for both x86 AVX2 & AVX-512 and Arm NEON & SVE 📐")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/SimSIMD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/SimSIMD.git")

    add_versions("v3.9.0", "8e79b628ba89beebc7c4c853323db0e10ebb6f85bcda2641e1ebaf77cfbda7f9")

    if is_plat("windows") then
        add_cxxflags("/arch:AVX2")
    else
        add_cxxflags("-march=native")
    end

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(
            package:check_csnippets({test = [[
                #include <simsimd/simsimd.h>

                int main() {
                    simsimd_f32_t vector_a[1536];
                    simsimd_f32_t vector_b[1536];
                    simsimd_f32_t distance = simsimd_avx512_f32_cos(vector_a, vector_b, 1536);
                    return 0;
                }
            ]]}, {config = {languages = "c11"}, includes = "simsimd/simsimd.h"})
        )
    end)
