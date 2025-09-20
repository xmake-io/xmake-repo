package("lyra")

    set_homepage("https://www.bfgroup.xyz/Lyra/")
    set_description("A simple to use, composable, command line parser for C++ 11 and beyond")
    set_license("BSL-1.0")

    add_urls("https://github.com/bfgroup/Lyra/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bfgroup/Lyra.git")
    add_versions("1.7.0", "d26b9e9dc1e08f88feaebc68965a6e5b25c7cd88617ce910d47cc83efb1e07d9")
    add_versions("1.5.1", "11ccdfc6f776b9a2ebe987d9b4e492981f88f3642546fd1c2e1115741863cae0")
    add_versions("1.6", "919e92a9c02fea3f365a3a7bdccd8b306311a28a7f2044dac8e7651106d7b644")
    add_versions("1.6.1", "a93f247ed89eba11ca36eb24c4f8ba7be636bf24e74aaaa8e1066e0954bec7e3")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                int width = 0;
                auto cli = lyra::cli()
                    | lyra::opt(width, "width")
                        ["-w"]["--width"]("How wide should it be?");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "lyra/lyra.hpp"}))
    end)
