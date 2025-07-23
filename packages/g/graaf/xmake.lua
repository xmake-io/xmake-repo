package("graaf")
    set_kind("library", {headeronly = true})
    set_homepage("https://bobluppes.github.io/graaf/")
    set_description("A general-purpose lightweight C++ graph library")
    set_license("MIT")

    add_urls("https://github.com/bobluppes/graaf/releases/download/$(version)/header-only.tar.gz",
             "https://github.com/bobluppes/graaf.git")

    add_versions("v1.1.1", "86a95e14aa18f81ea31ec0764ef8b12d1fe42396da3be0046e0dbbb562fb3c89")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                enum class fruit { orange, apple };
                void test() {
                    using enum fruit;
                }
            ]]}, {configs = {languages = "c++20"}}), "package(graaf) Require at least C++20.")
        end)
    end

    on_install(function (package)
        if package:gitref() then
            os.cp("include", package:installdir())
        else
            os.cp("graaflib", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                graaf::directed_graph<int, int> graph{};
            }
        ]]}, {configs = {languages = "c++20"}, includes = "graaflib/graph.h"}))
    end)
