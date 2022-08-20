package("cmdline")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tanakh/cmdline")
    set_description("A Command Line Parser")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/tanakh/cmdline.git")
    add_versions("2014.2.4", "e4cd007fb8f0314002d9a5b4d82939106e4144e4")

    on_install("linux", "macosx", "bsd", "mingw", function (package)
        os.cp("cmdline.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cmdline.h>
            using namespace std;
            static void test() {
                cmdline::parser a;
                a.add<string>("host", 'h', "host name", true, "");
                a.add<int>("port", 'p', "port number", false, 80, cmdline::range(1, 65535));
                a.add<string>("type", 't', "protocol type", false, "http", cmdline::oneof<string>("http", "https", "ssh", "ftp"));
                a.add("gzip", '\0', "gzip when transfer");
            }
        ]]}))
    end)
