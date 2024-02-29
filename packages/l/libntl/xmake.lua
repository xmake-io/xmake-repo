package("libntl")

    set_homepage("https://libntl.org/")
    set_description("NTL: A Library for doing Number Theory")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libntl/ntl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libntl/ntl.git")
    add_versions("v11.5.1", "ef578fa8b6c0c64edd1183c4c303b534468b58dd3eb8df8c9a5633f984888de5")

    add_deps("gmp")

    on_install("macosx|native", "linux|native", function (package)
        local cxxflags = table.wrap(package:build_getenv("cxxflags"))
        local ldflags = table.wrap(package:build_getenv("ldflags"))
        local gmp = package:dep("gmp"):fetch()
        if gmp then
            for _, includedir in ipairs(gmp.includedirs or gmp.sysincludedirs) do
                table.insert(cxxflags, "-I" .. includedir)
            end
            for _, linkdir in ipairs(gmp.linkdirs) do
                table.insert(ldflags, "-Wl,-L" .. linkdir)
            end
        end

        local compiler = package:build_getenv("cxx")
        if package:is_plat("macosx") then
            local cc = package:build_getenv("ld")
            if cc and cc:find("clang", 1, true) and cc:find("Xcode", 1, true) then
                compiler = "xcrun --sdk macosx clang++"
            end
        end
        compiler = compiler:gsub("gcc$", "g++")
        compiler = compiler:gsub("clang$", "clang++")

        os.cd("src")
        os.vrunv("./configure", {
            "CXX=" .. compiler,
            "CXXFLAGS=" .. table.concat(cxxflags, " "),
            "AR=" .. (package:build_getenv("ar") or "ar"),
            "ARFLAGS=" .. table.concat(table.wrap(package:build_getenv("arflags") or "ruv"), " "),
            "RANLIB=" .. (package:build_getenv("ranlib") or "ranlib"),
            "LDFLAGS=" .. table.concat(ldflags, " "),
            "CPPFLAGS=" .. table.concat(table.wrap(package:build_getenv("cppflags")), " "),
            "PREFIX=" .. package:installdir(),
            "SHARED=" .. (package:config("shared") and "on" or "off")
        }, {shell = true})
        os.vrunv("make", {})
        os.vrunv("make", {"install"})
        if package:config("shared") then
            os.rm(path.join(package:installdir(), "lib", "libntl.a"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <NTL/ZZ.h>
            #include <iostream>
            #include <cassert>
            void test() {
                NTL::ZZ a{2}, b{3}, c;
                c = (a + 1) * (b + 1);
                std::cout << c << std::endl;
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
