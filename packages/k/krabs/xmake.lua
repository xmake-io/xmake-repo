package("krabs")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/krabsetw")
    set_description("KrabsETW provides a modern C++ wrapper and a .NET wrapper around the low-level ETW trace consumption functions.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/krabsetw.git", {includes = "krabs"})
    add_versions("2025.12.16", "eaa17e2f9204496af81e3ca207450fdc7c6956f7")

    on_install("windows", function (package)
        os.vcp("krabs/krabs.hpp", package:installdir("include"))
        os.vcp("krabs/krabs", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                krabs::user_trace trace;
                krabs::provider<> provider(krabs::guid(L"{A0C1853B-5C40-4B15-8766-3CF1C58F985A}"));
                provider.any(0xf0010000000003ff);
            }
        ]]}, {configs = {languages = "c++17", defines = {"WIN32_LEAN_AND_MEAN", "UNICODE"}}, includes = "krabs.hpp"}))
    end)
