package("vectorial")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/scoopr/vectorial")
    set_description("Vector math library with NEON/SSE support")

    add_urls("https://github.com/scoopr/vectorial.git")
    add_versions("2019.06.28", "3a00e8c00d017cb49b12eeffd7464246d172ea97")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "vectorial/simd4f.h"
            void test() {
                simd4f a = simd4f_create(1,2,3,4);
                simd4f x = simd4f_sum(a);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
