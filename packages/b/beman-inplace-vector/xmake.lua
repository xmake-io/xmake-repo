package("beman-inplace-vector")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bemanproject/inplace_vector")
    set_description("A dynamically-resizable vector with fixed capacity and embedded storage (P0843)")
    set_license("Apache-2.0 WITH LLVM-exception")

    add_urls("https://github.com/bemanproject/inplace_vector/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/bemanproject/inplace_vector.git")
    add_versions("0.1.0", "945486eec583b123b09b08be661e9dee05c36244aeb5b022d3a6119250fc5bbc")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) >= 27, "package(beman-inplace-vector): require ndk >= 27")
        end)
    end

    on_install(function (package)
        os.cp("include/beman/inplace_vector/*.hpp", package:installdir("include/beman/inplace_vector"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <beman/inplace_vector/inplace_vector.hpp>
            void test() {
                beman::inplace_vector::inplace_vector<int, 4> v;
                v.push_back(42);
                v.emplace_back(7);
                (void)v.front();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
