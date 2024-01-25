package("glpk")
    set_homepage("https://www.gnu.org/software/glpk/")
    set_description("The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.")
    set_license("GPL-3.0")

    set_urls("https://ftp.gnu.org/gnu/glpk/glpk-$(version).tar.gz")

    add_versions("5.0", "4a1013eebb50f728fc601bdd833b0b2870333c3b3e5a816eeba921d95bec6f15")

    if is_plat("linux") then
        add_extsources("apt::libglpk-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <glpk.h>
            int main() {
              glp_prob* prob = glp_create_prob();
              if (prob) {
                glp_delete_prob(prob);
              }
              return 0;
            }
        ]]}))
    end)
