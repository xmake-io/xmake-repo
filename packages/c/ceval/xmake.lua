package("ceval")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/erstan/ceval")
    set_description("A C/C++ library for parsing and evaluation of arithmetic expressions.")
    set_license("MIT")

    add_urls("https://github.com/erstan/ceval/archive/refs/tags/$(version).tar.gz",
             "https://github.com/erstan/ceval.git")
    add_versions("1.0.1", "fb5508fc40715d1f1a50a1fa737f3c88cb7aeb187fb2aede7c35f0758f277779")
    add_versions("1.0.0", "3bb8cca8f0f7bf6f5ee6e7198d1174eab4d493318b6d97cc739343017090573e")

    on_install(function (package)
        io.replace("core/parser.h", "malloc.h", "stdlib.h", {plain = true})
        os.mkdir(path.join(package:installdir("include"), "ceval"))
        os.cp("ceval.h", path.join(package:installdir("include"), "ceval", "ceval.h"))
        os.cp("core", path.join(package:installdir("include"), "ceval"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                ceval_tree("1+1");
                ceval_result("1+1");
            }
        ]]}, {includes = "ceval/ceval.h"}))
    end)
