package("taywee_args")

    set_kind("library", {headeronly = true})
    set_homepage("https://taywee.github.io/args/")
    set_description("A simple header-only C++ argument parser library.")
    set_license("MIT")

    add_urls("https://github.com/Taywee/args/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Taywee/args.git")
    add_versions("6.3.0", "e072c4a9d6990872b0ecb45480a5487db82e0dc3d27c3c3eb9fc0930c0d796ae")
    add_versions("6.4.6", "41ed136bf9b216bf5f18b1de2a8d22a870381657e8427d6621918520b6e2239c")

    on_install(function (package)
        os.cp("args.hxx", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                args::ArgumentParser parser("This is a test program.", "This goes after the options.");
                args::HelpFlag help(parser, "help", "Display this help menu", {'h', "help"});
                args::CompletionFlag completion(parser, {"complete"});
                parser.ParseCLI(argc, argv);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "args.hxx"}))
    end)
