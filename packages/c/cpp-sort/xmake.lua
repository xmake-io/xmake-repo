package("cpp-sort")
    set_kind("library", {headeronly = true}) 
    set_homepage("https://github.com/Morwenn/cpp-sort")
    set_description("Sorting algorithms & related tools for C++14")
    set_license("MIT")

    add_urls("https://github.com/Morwenn/cpp-sort/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Morwenn/cpp-sort.git")

    add_versions("1.17.1", "addbcb6699b701f7a932d9b3cb53d8546e8f9e2bf9555962f864dbb43fc08de3")
    add_versions("1.17.0", "df6cbb805ff71e1b0a30fc1ed55696a2d8c70c3ab87447bee2b749e02415432e")
    add_versions("1.16.0", "54eb65de5655ce58719d45616f29e4b9060135b9cc8b526bcfc9f5434975ea8c")
    add_versions("1.10.0", "48951cac0051d48fee286c3bc02804975f9d83269d80c10dfc5589e76a542765")
    add_versions("1.11.0", "a53b3ea240d6f8d8ea9da0a7e0c8e313cf5e714daedf1617473ab34f111ffeec")
    add_versions("1.12.0", "70877c1993fa1e5eb53974ac30aeb713448c206344379f193dec8ee887c23998")
    add_versions("1.12.1", "5b0b6f3b4d9ecc339d6c2204a18479edca49fbc4d487413e0ec747e143569e2a")
    add_versions("1.13.0", "646eca5c592d20cbde0fbff41c65527940bb6430be68e0224fb5fcbf38b0df92")
    add_versions("1.13.1", "139912c6004df8748bb1cfd3b94f2c6bfc2713885ed4b8e927a783d6b66963a8")
    add_versions("1.13.2", "f5384ed9c8abef2f26cb010df2687ac8bba52f0e1726935826a80e83c1347b23")
    add_versions("1.14.0", "3b85cd4580f54ae3f171777d0630b4f7c89c33cf96e9ae24a1dbebbf200c3195")
    add_versions("1.15.0", "886e813a4b87c6361e9b50c0a66c73b3b812f0ce0b7039ff3991eddce77e0dc7")

    if is_plat("windows") then
        add_cxxflags("/permissive-")
    end

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <array>
            #include <cpp-sort/sorters/smooth_sorter.h>
            void test() {
                std::array<int, 5> arr = { 5, 8, 3, 2, 9 };
                cppsort::smooth_sort(arr);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
