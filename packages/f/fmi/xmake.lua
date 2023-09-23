package("fmi")
    set_kind("library", {headeronly = true})
    set_homepage("https://fmi-standard.org/")
    set_description("Specification of the Functional Mock-Up Interface (FMI)")

    add_urls("https://github.com/modelica/fmi-standard/archive/refs/tags/$(version).tar.gz",
             "https://github.com/modelica/fmi-standard.git")

    add_versions("v3.0.1", "aba8c3b6d67484926fada2cf7433ad10c6b3b3fc4f84df7dc90230609ea257c1")

    on_install(function (package)
        os.cp("headers/*.h", package:installdir("include"))
        os.cp("schema", package:installdir("share"))
    end)

    on_test(function (package)
        assert(package:has_ctypes("fmi3Status", {includes = "fmi3FunctionTypes.h"}))
    end)
