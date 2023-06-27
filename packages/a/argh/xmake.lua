package("argh")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/adishavit/argh")
    set_description("Argh! A minimalist argument handler.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/adishavit/argh/archive/refs/tags/$(version).tar.gz",
             "https://github.com/adishavit/argh.git")
    add_versions("v1.3.2", "4b76d8c55e97cc0752feee4f00b99dc58464dd030dea9ba257c0a7d24a84f9dd")

    on_install(function (package)
        os.cp("argh.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            using namespace std;
                    
            int test(int argc, char* argv[]) {
                argh::parser cmdl;
                cmdl.parse(argc, argv, argh::parser::PREFER_PARAM_FOR_UNREG_OPTION);
                if (cmdl["-v"]) cout << "Verbose, I am." << endl;
                cout << "Positional args:\n";
                for (auto& pos_arg : cmdl) cout << '\t' << pos_arg << endl;
                cout << "\nFlags:\n";
                for (auto& flag : cmdl.flags()) cout << '\t' << flag << endl;
                cout << "\nParameters:\n";
                for (auto& param : cmdl.params()) cout << '\t' << param.first << " : " << param.second << endl;
                return EXIT_SUCCESS;
            }
        ]]}, {configs = {languages = "cxx17"}, includes = "argh.h"}))
    end)
