package("think-cell-library")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.think-cell.com/en/career/devblog/overview")
    set_description("Think-cell core library")
    set_license("BSL-1.0")

    add_urls("https://github.com/think-cell/think-cell-library/archive/refs/tags/$(version).tar.gz",
             "https://github.com/think-cell/think-cell-library.git")

    add_versions("2023.1", "d5796bcef876e1260720961e31ebc537d9320d5e97b6d7ba6153b633da992756")

    add_deps("boost", {configs = {filesystem = true, container = true}})

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(think-cell-library) require ndk version > 22")
    end)

    on_install("!wasm", function (package)
        io.replace("tc/string/spirit.h", [[#include "spirit/x3.hpp"]], "#include <boost/spirit/home/x3.hpp>", {plain = true})
        os.cp("tc/**.h", package:installdir("include/tc"), {rootdir = "tc"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <tc/range/meta.h>
            #include <tc/range/filter_adaptor.h>
            void test() {
                std::vector<int> v = {1,2,3,4};
                tc::for_each(tc::filter(v, [](const int& n){ return (n%2==0);}), [&](auto const& n) {});
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
