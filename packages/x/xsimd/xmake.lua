package("xsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xsimd/")
    set_description("C++ wrappers for SIMD intrinsics")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xsimd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xsimd.git")

    add_versions("14.0.0", "17de0236954955c10c09d6938d4c5f3a3b92d31be5dadd1d5d09fc1b15490dce")
    add_versions("13.2.0", "edd8cd3d548c185adc70321c53c36df41abe64c1fe2c67bc6d93c3ecda82447a")
    add_versions("13.1.0", "88c9dc6da677feadb40fe09f467659ba0a98e9987f7491d51919ee13d897efa4")
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
                #include "xsimd/xsimd.hpp"

                namespace xsimd {
                template <class arch>
                inline batch<int, arch> mandel(const batch_bool<float, arch> &_active,
                                               const batch<float, arch> &c_re,
                                               const batch<float, arch> &c_im, int maxIters) {
                    using float_batch_type = batch<float, arch>;
                    using int_batch_type = batch<int, arch>;

                    float_batch_type z_re = c_re;
                    float_batch_type z_im = c_im;
                    int_batch_type vi(0);
                    return vi;
                }
                }  // namespace xsimd

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
