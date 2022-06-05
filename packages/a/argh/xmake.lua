package("argh")
    set_homepage("https://github.com/adishavit/argh")
    set_description("Argh! A minimalist argument handler.")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/adishavit/argh.git")
    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>

            using namespace std;

            #include "argh.h"

            int test(int argc, char* argv[])
            {
                argh::parser cmdl;
                cmdl.parse(argc, argv, argh::parser::PREFER_PARAM_FOR_UNREG_OPTION);

                if (cmdl["-v"])
                    cout << "Verbose, I am." << endl;

                cout << "Positional args:\n";
                for (auto& pos_arg : cmdl)
                    cout << '\t' << pos_arg << endl;

                cout << "Positional args:\n";
                for (auto& pos_arg : cmdl.pos_args())
                    cout << '\t' << pos_arg << endl;

                cout << "\nFlags:\n";
                for (auto& flag : cmdl.flags())
                    cout << '\t' << flag << endl;

                cout << "\nParameters:\n";
                for (auto& param : cmdl.params())
                    cout << '\t' << param.first << " : " << param.second << endl;

                return EXIT_SUCCESS;
            }
        ]]}, {configs = {languages = "cxx17"}, includes = "argh.h"}))
    end)
package_end()
