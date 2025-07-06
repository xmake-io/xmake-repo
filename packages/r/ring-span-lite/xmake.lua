package("ring-span-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/ring-span-lite")
    set_description("ring-span lite - A C++yy-like ring_span type for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/ring-span-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/ring-span-lite.git")

    add_versions("v0.7.0", "7650bb1bcf76cb0f7ac75240c5346203cbe7eb7027c0843c60253f6db08a93c1")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DRING_SPAN_LITE_OPT_BUILD_TESTS=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            template< typename T, size_t N >
            inline size_t dim( T (&arr)[N] ) { return N; }
            void test() {
                double arr[]   = { 2.0 , 3.0, 5.0, };
                double coeff[] = { 0.25, 0.5, 0.25 };
                nonstd::ring_span<double> buffer( arr, arr + dim(arr), arr, dim(arr) );
            }
        ]]}, {includes = "nonstd/ring_span.hpp"}))
    end)
