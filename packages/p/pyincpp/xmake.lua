package("pyincpp")
    set_homepage("https://github.com/chen-qingyu/pyincpp")
    set_description("A C++ type library that is as easy to use as Python built-in types.")
    set_kind("library", {headeronly = true})

    add_urls("https://github.com/chen-qingyu/pyincpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/chen-qingyu/pyincpp.git")

    add_versions("v2.3.0", "e10640c03a6ae9365a299f57a68a5f2a873146b07f92fd33bc4f673e21d68072")

    on_install(function (package)
        os.cp("sources/*.hpp", package:installdir("include/"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {} // https://github.com/xmake-io/xmake-repo/issues/4052
        ]]}, {configs = {languages = "c++20"}}))
    end)
