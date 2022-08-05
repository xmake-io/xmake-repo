package("kiwisolver")

    set_homepage("https://kiwisolver.readthedocs.io/en/latest/")
    set_description("Efficient C++ implementation of the Cassowary constraint solving algorithm")

    add_urls("https://github.com/nucleic/kiwi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nucleic/kiwi.git")
    add_versions("1.4.4", "d41997519fcba4a1e46eb4a2fe31bc12f0ff957b2b81bac28db24744f333e955")
    add_versions("1.3.2", "36f3ceecd52aa16d5aebf5a6b6f3ba4e471de5bc95e634066393e4ef1f0d6ff1")
    add_versions("1.3.1", "91d56ec628be2513a02c3721d4d8173416daf37c49423fe7a41a0e30c1101269")

    on_install(function (package)
        os.cp("kiwi", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                kiwi::Solver solver;

                kiwi::Variable x1("x1");
                kiwi::Variable x2("x2");
                kiwi::Variable xm("xm");

                kiwi::Constraint constraints[] = {
                    x1 >= 0,
                    x2 <= 100,
                    x2 >= x1 + 20,
                    xm == (x1 + x2) / 2
                };

                for (auto& constraint : constraints)
                    solver.addConstraint(constraint);

                solver.addConstraint(x1 == 40 | kiwi::strength::weak);
                solver.addEditVariable(xm, kiwi::strength::strong);
                solver.suggestValue(xm, 60);
                solver.updateVariables();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "kiwi/kiwi.h"}))
    end)
