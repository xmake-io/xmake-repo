package("randx")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lidaixingchen/RandX")
    set_description("Modern, fast, and header-only C++ pseudo-random number generator and distribution library (C++17/C++23).")
    set_license("MIT")

    add_urls("https://github.com/lidaixingchen/RandX/archive/refs/tags/v$(version).tar.gz")

    add_versions("1.4.2", "dc816718ab8a42e3fa34a6e56444f580a1539b9b21b462713e434a0f88d16b5b")
    add_versions("1.4.0", "ecf611c6f340986df2abf3191def2222a3287f5e20ec4280c88996770a95eec7")
    add_versions("1.3.1", "f271bbcb26bea7747ee292646df895c2305b696bb0d58d69b54e84fe96fab3c1")

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt")
    elseif is_plat("macosx") then
        add_frameworks("Security")
    end

    on_install(function (package)
        os.cp("RandX.hpp", package:installdir("include"))
        os.cp("RandX_Cpp17.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <RandX_Cpp17.hpp>
            #include <cstdint>
            static void test() {
                std::uint64_t v = RandX::RandInt<std::uint64_t>(0, 1000);
                (void)v;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
