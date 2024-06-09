package("plf_rand")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/rand.htm")
    set_description("A replacement for rand()/srand() that's ~700% faster with (typically) better statistical distribution. An adaptation of PCG with fallback to xorshift for C++98/03.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_rand.git")
    add_versions("v1.05", "764684817b0208b9f18b4b3d18f4f8d8f33fa1f0")

    on_install(function (package)
        os.cp("plf_rand.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plf_rand.h>
            void test() {
                plf::rand();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
