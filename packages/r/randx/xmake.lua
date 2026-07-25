package("randx")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lidaixingchen/RandX")
    set_description("Modern, fast, and header-only C++ pseudo-random number generator and distribution library (C++17/C++23).")
    set_license("MIT")

    add_urls("https://github.com/lidaixingchen/RandX/archive/refs/tags/v$(version).tar.gz")

    add_versions("1.4.2", "25badb73e98b2e83456bea63bb60b1f335091576ec1d1c06ec2649ed92fc84bf")
    add_versions("1.4.0", "ecf611c6f340986df2abf3191def2222a3287f5e20ec4280c88996770a95eec7")

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt")
    elseif is_plat("macosx") then
        add_frameworks("Security")
    end

    on_install(function (package)
        os.cp("RandX.hpp", package:installdir("include"))
        os.cp("RandX_Cpp17.hpp", package:installdir("include"))
        -- Header-only: create empty archive so -lrandx resolves in find_package checks
        if not package:is_plat("windows") then
            local libfile = package:installdir("lib", "librandx.a")
            os.mkdir(path.directory(libfile))
            io.writefile(libfile, "!<arch>\n")
        end
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
