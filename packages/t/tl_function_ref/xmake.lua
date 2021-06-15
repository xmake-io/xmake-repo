package("tl_function_ref")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/TartanLlama/function_ref")
    set_description("A lightweight, non-owning reference to a callable.")
    set_license("CC0")

    set_urls("https://github.com/TartanLlama/function_ref/archive/$(version).zip",
             "https://github.com/TartanLlama/function_ref.git")

    add_versions("v1.0.0", "b3161fddbf40b41be984d5649ad6b5790ecebd0388f9db51b3160ecd006963f4")

    on_install(function (package)
        os.cp("include/tl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                tl::function_ref<void(void)> fr1 = []{};
            }
        ]]}, {configs = {languages = "c++14"}, includes = { "tl/function_ref.hpp"} }))
    end) 
