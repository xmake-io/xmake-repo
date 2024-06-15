package("antlr4")
    set_kind("binary")
    set_homepage("https://www.antlr.org")
    set_description("powerful parser generator for reading, processing, executing, or translating structured text or binary files.")
    set_license("BSD-3-Clause")

    add_urls("https://www.antlr.org/download/antlr-$(version)-complete.jar")
    add_versions("4.13.1", "bc13a9c57a8dd7d5196888211e5ede657cb64a3ce968608697e4f668251a8487")

    add_deps("openjdk")

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", "macosx|arm64", "mingw|x86_64", function (package)
        local source = "antlr-" .. package:version() .. "-complete.jar"
        local target = path.join(package:installdir("lib"), "antlr-complete.jar")
        os.vcp("../" .. source, package:installdir("lib"))
        os.vmv(package:installdir("lib", source), target)
        package:addenv("CLASSPATH", target)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("java -classpath $(env CLASSPATH) org.antlr.v4.Tool")
        end
    end)
