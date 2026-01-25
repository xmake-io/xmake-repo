package("zpp_bits")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/eyalz800/zpp_bits")
    set_description("A lightweight C++20 serialization and RPC library")
    set_license("MIT")

    add_urls("https://github.com/eyalz800/zpp_bits/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eyalz800/zpp_bits.git")

    add_versions("v4.6", "ca5889fd2328df7411c0e4f4ddd64b396277dec5ed589b5f009dadc36ef3a24d")
    add_versions("v4.5.1", "2589469c86700264e4746b3efb0319b6911f2b9899fbd7cefddb6a01a7001f3b")
    add_versions("v4.5", "2ed5058b1394cd79b5130916e6beb275efbfb73f1713ed1d08a7d3ba1b36970e")
    add_versions("v4.4.25", "d4afb8cf73aec19686928445e912dbbe8d39bffdac43ea69b4781f145195a09e")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(zpp_bits) require ndk version > 22")
        end)
    end

    on_install(function (package)
        os.vcp("zpp_bits.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto [data, in, out] = zpp::bits::data_in_out();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "zpp_bits.h"}))
    end)
