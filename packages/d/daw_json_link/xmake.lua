package("daw_json_link")
    set_kind("library", {headeronly = true})
    set_homepage("https://beached.github.io/daw_json_link/")
    set_description("Fast, convenient JSON serialization and parsing in C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/beached/daw_json_link/archive/refs/tags/$(version).tar.gz",
             "https://github.com/beached/daw_json_link.git")

    add_versions("v3.31.0", "d7a88daee76fdd6c37cb1bc4bc1a28b1eaeb461525767428ecc64b28b1dd20d0")
    add_versions("v3.30.2", "30a132265ee9c9a94716ed9e5bd00c766c05aede74c3d2885dbaccb2ed067141")
    add_versions("v3.29.2", "a0450a2d724d83a600d48d503eb11094039a7a4b607fa59b1d7ce83483b1f8b4")
    add_versions("v3.28.3", "c9973e8da74c4a6eb84fbd1f86f8048a697068af7dec6aee602e08e9f4df39db")
    add_versions("v3.26.0", "c3eb3e37eba2eb919a908ef0be4c0f1c02460a677248a1b4298bfbe1bb2d9239")
    add_versions("v3.24.1", "439b4678377950f165e3d49d472c0676f0ef2fae3c5e6e7febddd5633f6e4f39")
    add_versions("v3.24.0", "7cecb2acde88028043e343ed4da7cde84c565a38125d3edb90db90daf881240a")
    add_versions("v3.23.2", "fd1234a14c126c79076e0b6e6eceae42afd465c419dc7a7393c69c28aa7f53d4")
    add_versions("v3.20.1", "046638bc4437d138cc8bdc882027d318ca3e267f33d1b419c5bdecb45b595a47")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(daw_json_link): need ndk api level > 21 for android")
        end)
    end

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android@linux,macosx", "iphoneos", "cross", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <daw/json/daw_json_link.h>
            void test() {
                std::string json_data = "[1, 2, 3, 4, 5]";
                auto const obj = daw::json::from_json_array<int>(json_data);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
