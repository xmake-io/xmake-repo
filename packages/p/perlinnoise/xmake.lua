package("perlinnoise")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Reputeless/PerlinNoise")
    set_description("Header-only Perlin noise library for modern C++ (C++17/C++20)")
    set_license("MIT")

    add_urls("https://github.com/Reputeless/PerlinNoise/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Reputeless/PerlinNoise.git")

    add_versions("v3.0.0", "1fea1e7ebeb3c66b79d60c2c398aa83ccfadcef343bd396c0f0a684380e827fc")

    on_install(function (package)
        os.cp("PerlinNoise.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            void test() {
                const siv::PerlinNoise::seed_type seed = 123456u;
                const siv::PerlinNoise perlin{ seed };
                for (int y = 0; y < 5; ++y) {
                    for (int x = 0; x < 5; ++x) {
                        const double noise = perlin.octave2D_01((x * 0.01), (y * 0.01), 4);
                    }
                }
            }
        ]], {configs = {languages = "c++17"}, includes = "PerlinNoise.hpp"}))
    end)
