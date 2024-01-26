package("glpk")
    set_homepage("https://www.gnu.org/software/glpk/")
    set_description("The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.")
    set_license("GPL-3.0")

    set_urls("https://ftp.gnu.org/gnu/glpk/glpk-$(version).tar.gz")

    add_versions("5.0", "4a1013eebb50f728fc601bdd833b0b2870333c3b3e5a816eeba921d95bec6f15")

    add_configs("shared", {description = "Build shared binaries", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libglpk-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_install("windows", function (package)
        os.cd(is_arch("x64", "x86_64") and "w64" or "w32")
        os.cp("config_VC", "config.h")
        import("package.tools.nmake").build(package, {"/f", package:config("shared") and "makefile_VC_DLL" or "makefile_VC"})

        if package:config("shared") then
            os.cp("glpk_5_0.dll", package:installdir("bin"))
            os.cp("glpk_5_0.lib", package:installdir("lib"))
        else
            os.cp("glpk.lib", package:installdir("lib"))
        end

        os.cd("..")
        os.cp("src/glpk.h", package:installdir("include"))
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
