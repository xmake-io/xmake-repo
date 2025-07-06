package("noisy")
    set_kind("library", {headeronly = true})
    set_homepage("https://vzalzal.com/posts/noisy-the-class-you-wrote-a-hundred-times/")
    set_description("A C++ type to trace calls to special member functions.")
    set_license("MIT")

    add_urls("https://github.com/VincentZalzal/noisy.git")
    add_versions("2024.04.22", "99810230e226a294fb2bf97e4a1bc8d734368a48")

    on_install(function (package)
        os.cp("noisy.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <noisy.h>
            vz::Noisy make_noisy() { return {}; }
            void test() {
                vz::Noisy x = vz::Noisy(make_noisy());
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
