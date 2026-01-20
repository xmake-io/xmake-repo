package("highway")
    set_homepage("https://github.com/google/highway")
    set_description("Performance-portable, length-agnostic SIMD with runtime dispatch")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/highway/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/highway.git")

    add_versions("1.3.0", "07b3c1ba2c1096878a85a31a5b9b3757427af963b1141ca904db2f9f4afe0bc2")
    add_versions("1.2.0", "7e0be78b8318e8bdbf6fa545d2ecb4c90f947df03f7aadc42c1967f019e63343")
    add_versions("1.1.0", "354a8b4539b588e70b98ec70844273e3f2741302c4c377bcc4e81b3d1866f7c9")

    add_configs("contrib", {description = "Build SIMD-related utilities", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DHWY_ENABLE_INSTALL=ON", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHWY_ENABLE_CONTRIB=" .. (package:config("contrib") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.tryrm(package:installdir("lib/*hwy_test*"))
        os.tryrm(package:installdir("bin/*hwy_test*"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <hwy/highway.h>
            namespace hn = hwy::HWY_NAMESPACE;
            using T = float;

            void test(const T* HWY_RESTRICT mul_array,
                            const T* HWY_RESTRICT add_array,
                            const size_t size, T* HWY_RESTRICT x_array) {
                const hn::ScalableTag<T> d;
                for (size_t i = 0; i < size; i += hn::Lanes(d)) {
                    const auto mul = hn::Load(d, mul_array + i);
                    const auto add = hn::Load(d, add_array + i);
                    auto x = hn::Load(d, x_array + i);
                    x = hn::MulAdd(mul, x, add);
                    hn::Store(x, d, x_array + i);
                }
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
