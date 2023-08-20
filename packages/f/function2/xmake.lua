package("function2")
    set_kind("library", {headeronly = true})
    set_homepage("http://naios.github.io/function2")
    set_description("Improved and configurable drop-in replacement to std::function that supports move only types, multiple overloads and more")
    set_license("BSL-1.0")

    add_urls("https://github.com/Naios/function2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Naios/function2.git")

    add_versions("4.1.0", "c3aaeaf93bf90c0f4505a18f1094b51fe28881ce202c3bf78ec4efb336c51981")
    add_versions("4.2.0", "fd1194b236e55f695c3a0c17f2440d6965b800c9309d0d5937e0185bcfe7ae6e")
    add_versions("4.2.1", "dfaf12f6cc4dadc4fc7051af7ac57be220c823aaccfd2fecebcb45a0a03a6eb0")
    add_versions("4.2.2", "f755cb79712dfb9ceefcf7f7ff3225f7c99d22a164dae109044dbfad55d7111e")
    add_versions("4.2.3", "097333b05e596280d3bc7a4769f1262931716cd8cc31ca7337b7af714085f3fc")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <function2/function2.hpp>
            void test() {
                fu2::function<void() const> fun = [] {};
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
