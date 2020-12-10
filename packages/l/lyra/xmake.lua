package("lyra")

    set_homepage("https://www.bfgroup.xyz/Lyra/")
    set_description("A simple to use, composable, command line parser for C++ 11 and beyond")
    set_license("BSL-1.0")

    add_urls("https://github.com/bfgroup/Lyra/archive/1.5.1.tar.gz",
             "https://github.com/bfgroup/Lyra.git")
    add_versions("1.5.1", "11ccdfc6f776b9a2ebe987d9b4e492981f88f3642546fd1c2e1115741863cae0")

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
