package("kiwisolver")
    set_kind("library", {headeronly = true})
    set_homepage("https://kiwisolver.readthedocs.io/en/latest/")
    set_description("Efficient C++ implementation of the Cassowary constraint solving algorithm")

    add_urls("https://github.com/nucleic/kiwi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nucleic/kiwi.git")
    add_versions("1.4.8", "e8848589c1548a292e99eadc712f14d8924e77f390b7de0a4a5359ee8e4a480f")
    add_versions("1.4.7", "5411b0e25bb1cd18f86b2fa4b17e6e66246b73be047377c6304a2e67aa492c71")
    add_versions("1.4.6", "ec022dbab778a3d133513ca8ff86f3fbecadc0ffdcea2f1006e51f87406076f4")
    add_versions("1.4.5", "2f3df2625993276a67a3ad312959f9c8333e23dfda0b7e5464b4927d34be6faa")
    add_versions("1.4.4", "230a40fb960274ba9d68bd83aecb0d9f880465e9ed85e0c686f2e8651addae99")
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
