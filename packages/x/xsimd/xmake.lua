package("xsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xsimd/")
    set_description("C++ wrappers for SIMD intrinsics")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xsimd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xsimd.git")

    add_versions("13.0.0", "8bdbbad0c3e7afa38d88d0d484d70a1671a1d8aefff03f4223ab2eb6a41110a3")
    add_versions("12.1.1", "73f94a051278ef3da4533b691d31244d12074d5d71107473a9fd8d7be15f0110")
    add_versions("7.6.0", "eaf47f1a316ef6c3287b266161eeafc5aa61226ce5ac6c13502546435b790252")
    add_versions("8.0.3", "d1d41253c4f82eaf2f369d7fcb4142e35076cf8675b9d94caa06ecf883024344")
    add_versions("8.0.5", "0e1b5d973b63009f06a3885931a37452580dbc8d7ca8ad40d4b8c80d2a0f84d7")
    add_versions("9.0.1", "b1bb5f92167fd3a4f25749db0be7e61ed37e0a5d943490f3accdcd2cd2918cc0")
    add_versions("10.0.0", "73f818368b3a4dad92fab1b2933d93694241bd2365a6181747b2df1768f6afdd")
    add_versions("11.0.0", "50c31c319c8b36c8946eb954c7cca2e2ece86bf8a66a7ebf321b24cd273e7c47")

    if is_plat("windows") then
        add_cxxflags("/arch:AVX2")
    else
        add_cxxflags("-march=native")
    end

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        if package:version():ge("8.0") then
            assert(package:check_cxxsnippets({test = [[
                #include <cstddef>
                #include <vector>
                #include "xsimd/xsimd.hpp"
                
                namespace xs = xsimd;
                using vector_type = std::vector<double, xsimd::aligned_allocator<double>>;
                
                void mean(const vector_type& a, const vector_type& b, vector_type& res)
                {
                    std::size_t size = a.size();
                    constexpr std::size_t simd_size = xsimd::simd_type<double>::size;
                    std::size_t vec_size = size - size % simd_size;
                
                    for(std::size_t i = 0; i < vec_size; i += simd_size)
                    {
                        auto ba = xs::load_aligned(&a[i]);
                        auto bb = xs::load_aligned(&b[i]);
                        auto bres = (ba + bb) / 2.;
                        bres.store_aligned(&res[i]);
                    }
                    for(std::size_t i = vec_size; i < size; ++i)
                    {
                        res[i] = (a[i] + b[i]) / 2.;
                    }
                }
                void test() {}
            ]]}, {configs = {languages = "c++14"}}))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <iostream>
                void test() {
                    xsimd::batch<double, 4> a(1.5, 2.5, 3.5, 4.5);
                    xsimd::batch<double, 4> b(2.5, 3.5, 4.5, 5.5);
                    auto mean = (a + b) / 2;
                    std::cout << mean << std::endl;
                }
            ]]}, {configs = {languages = "c++14"}, includes = "xsimd/xsimd.hpp"}))
        end
    end)
