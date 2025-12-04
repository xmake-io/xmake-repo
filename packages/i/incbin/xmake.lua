package("incbin")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/graphitemaster/incbin")
    set_description("Include binary files in C/C++")
    set_license("Unlicense")

    add_urls("https://github.com/graphitemaster/incbin.git")

    add_versions("2025.05.27", "22061f51fe9f2f35f061f85c2b217b55dd75310d")

    on_install("!wasm", function (package)
        os.cp("incbin.h", package:installdir("include"))
    end)

    on_test(function (package)
        io.writefile("test.txt", "hello world!")
        assert(package:check_cxxsnippets({test = [[
            #include <incbin.h>
            INCBIN(test, "test.txt");
            void test() {
                const unsigned char* data = gtestData;
                int size = gtestSize;
            }
        ]]}))
    end)
