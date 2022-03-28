package("z3")

    set_homepage("https://github.com/Z3Prover/z3")
    set_description("Z3 is a theorem prover from Microsoft Research.")
    set_license("MIT")

    add_urls("https://github.com/Z3Prover/z3/releases/download/z3-$(version)/z3-solver-$(version).0.tar.gz")
    add_versions("4.8.15", "4f1612fcca67eba92bb1752182e6e659d0607ae5d88d8db99a07451ed7f8ff49")

    add_deps("python 3.x", {kind = "binary"})
    if is_plat("linux") then
        add_syslinks("pthread", "rt")
    end
    on_install("windows", function (package)
        os.cd("core")
        io.gsub("scripts/mk_project.py", " *add_[^\n]-_example%([^\n]-%)", "")
        local args = {"scripts/mk_make.py"}
        table.insert(args, "--python")
        if package:debug() then
            table.insert(args, "--debug")
        end
        if package:is_arch("x64") then
            table.insert(args, "--x64")
        end
        if package:config("shared") then
            table.insert(args, "--staticlib")
        end
        if package:config("vs_runtime"):startswith("MT") then
            table.insert(args, "--staticbin")
        end
        os.vrunv("python", args)
        for _, header in ipairs({"z3_algebraic.h", "z3_api.h", "z3_ast_containers.h", "z3_fixedpoint.h", "z3_fpa.h", "z3.h", "c++/z3++.h", "z3_macros.h", "z3_optimization.h", "z3_polynomial.h", "z3_rcf.h", "z3_v1.h", "z3_spacer.h"}) do
            os.cp(path.join("src", "api", header), package:installdir("include"))
        end
        os.cd("build")
        import("package.tools.nmake").build(package)
        os.cp("z3.exe", package:installdir("bin"))
        os.cp("python", package:installdir())
        if package:config("shared") then
            os.cp("libz3.dll", package:installdir("bin"))
            os.cp("libz3.lib", package:installdir("lib"))
        else
            os.cp("libz3-static.lib", package:installdir("lib"))
        end
        package:addenv("PATH", "bin")
        package:addenv("PYTHONPATH", "python")
    end)

    on_install("macosx", "linux", function (package)
        os.cd("core")
        io.gsub("scripts/mk_project.py", " *add_[^\n]-_example%([^\n]-%)", "")
        local args = {"scripts/mk_make.py"}
        table.insert(args, "--prefix=" .. package:installdir())
        table.insert(args, "--python")
        table.insert(args, "--pypkgdir=" .. package:installdir("python"))
        if package:debug() then
            table.insert(args, "--debug")
        end
        if package:is_arch("x86") then
            table.insert(args, "--x86")
        end
        if not package:config("shared") then
            table.insert(args, "--staticlib")
            table.insert(args, "--staticbin")
        end
        os.vrunv("python", args)
        os.cd("build")
        import("package.tools.make").install(package)
        if not package:config("shared") then
            -- allow python to find libz3.so
            os.mv(path.join(package:installdir("lib"), "libz3.so"), package:installdir("python"))
            package:addenv("LD_LIBRARY_PATH", "python")
        end
        package:addenv("PATH", "bin")
        package:addenv("PYTHONPATH", "python")
    end)

    on_test(function (package)
        os.vrun("z3 -version")
        assert(package:has_cfuncs("Z3_mk_config", {includes = "z3.h"}))
    end)
