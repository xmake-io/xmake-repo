package("antlr4")
    set_kind("binary")
    set_homepage("https://www.antlr.org")
    set_description("powerful parser generator for reading, processing, executing, or translating structured text or binary files.")
    set_license("BSD-3-Clause")

    add_urls("https://www.antlr.org/download/antlr-$(version)-complete.jar")

    add_versions("4.13.2", "eae2dfa119a64327444672aff63e9ec35a20180dc5b8090b7a6ab85125df4d76")
    add_versions("4.13.1", "bc13a9c57a8dd7d5196888211e5ede657cb64a3ce968608697e4f668251a8487")

    if is_plat("linux") then
        add_extsources("pacman::antlr4", "apt::antlr4")
    elseif is_plat("macosx") then
        add_extsources("brew::antlr")
    end

    set_policy("package.precompiled", false)

    add_deps("openjdk")

    on_load(function (package)
        package:mark_as_pathenv("CLASSPATH")
        package:addenv("CLASSPATH", "lib/antlr-complete.jar")
    end)

    on_install("@windows", "@linux", "@macosx", function (package)
        os.vcp(package:originfile(), path.join(package:installdir("lib"), "antlr-complete.jar"))
    end)

    on_test(function (package)
        os.vrun("java -classpath $(env CLASSPATH) org.antlr.v4.Tool")
    end)
