package("mathter")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/petiaccja/Mathter")
    set_description("A flexible and fast matrix, transform and geometry library.")
    set_license("MIT")

    add_urls("https://github.com/petiaccja/Mathter/archive/refs/tags/$(version).tar.gz",
             "https://github.com/petiaccja/Mathter.git")

    add_versions("v1.1.2", "9e6d03295d28e8792721fedca5d53955d4057d1550e51491408353b6181e6c6d")
    add_versions("v1.1.1", "510e6aa198cd7b207a44d319e4471021f207cba8c4d2d7e40086f1f042fe13ab")

    add_configs("xsimd", {description = "Uses XSimd for vectorization of math routines. Uses scalar fallback if turned off.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("xsimd") then
            package:add("deps", "xsimd")
            package:add("defines", "MATHTER_USE_XSIMD")
        end
    end)

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace mathter;
            using Vec2 = Vector<float, 2, false>;
            void test() {
                Vec2 a = { 1, 2 };
            }
        ]]}, {configs = {languages = "c++17"}, includes = "Mathter/Vector.hpp"}))
    end)
