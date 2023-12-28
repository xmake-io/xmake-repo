package("zpp_throwing")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/eyalz800/zpp_throwing")
    set_description("Using coroutines to implement C++ exceptions for freestanding environments")
    set_license("MIT")

    add_urls("https://github.com/eyalz800/zpp_throwing/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eyalz800/zpp_throwing.git")

    add_versions("v1.0.1", "c15651ad36f9ddcb51e6244b0a78dbdebf7be8748b3e7ffe1c7339f0e41fd411")

    on_install("linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        os.cp("zpp_throwing.h", package:installdir("include"))
    end)

    on_test(function (package)
        local cxxflags
        if package:is_plat("windows") then
            cxxflags = {"/EHsc-", "/GR-"}
        else
            cxxflags = {"-fno-exceptions", "-fno-rtti"}
        end
        assert(package:check_cxxsnippets({test = [[
            #include <zpp_throwing.h>
            zpp::throwing<int> test(bool success) {
                if (!success) {
                    co_yield std::runtime_error("My runtime error");
                }
                co_return 1337;
            }
        ]]}, {configs = {languages = "c++20", cxxflags = cxxflags}}))
    end)
