package("glpk")
    set_homepage("https://www.gnu.org/software/glpk/")
    set_description("The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.")
    set_license("GPL-3.0")

    set_urls("https://ftp.gnu.org/gnu/glpk/glpk-$(version).tar.gz")

    add_versions("5.0", "4a1013eebb50f728fc601bdd833b0b2870333c3b3e5a816eeba921d95bec6f15")

    if is_plat("linux") then
        add_extsources("apt::libglpk-dev")
    end

    on_install("macosx|x86_64", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows", function (package)
        os.cd("w64") -- Makefiles are the same in w64 and w32 directory
        os.cp("config_VC", "config.h")
        local version = package:version()
        local basename = string.format("glpk_%d_%d", version:major(), version:minor())
         -- glp_netgen_prob is not defined, but should be disabled
         -- see: https://www.mail-archive.com/bug-glpk@gnu.org/msg01020.html
        io.replace(basename .. ".def", "glp_netgen_prob\n", "", {plain = true})
        import("package.tools.nmake").build(package, {"/f", package:config("shared") and "makefile_VC_DLL" or "makefile_VC"})

        if package:config("shared") then
            os.cp(basename .. ".dll", package:installdir("bin"))
            os.cp(basename .. ".lib", package:installdir("lib"))
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
