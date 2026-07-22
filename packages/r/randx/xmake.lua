package("randx")
    set_homepage("https://github.com/lidaixingchen/RandX")
    set_description("Modern, fast, and header-only C++ pseudo-random number generator and distribution library (C++17/C++23).")
    set_license("MIT")

    add_urls("https://github.com/lidaixingchen/RandX/archive/refs/tags/v$(version).tar.gz")

    add_versions("1.3.1", "f271bbcb26bea7747ee292646df895c2305b696bb0d58d69b54e84fe96fab3c1")

    on_load(function (package)
        package:set("kind", "library", {headeronly = true})

        -- 跨平台 OS 熵源链接（ChaCha20 CSPRNG 需要）
        -- Windows: BCryptGenRandom → bcrypt
        -- macOS:   SecRandomCopyBytes → Security framework
        -- Linux:   getrandom → libc 内置，无需额外链接
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "bcrypt")
        elseif package:is_plat("macosx") then
            package:add("syslinks", "Security")
        end
    end)

    on_install(function (package)
        -- 仅安装两个头文件到 include/
        os.cp("RandX.hpp", package:installdir("include"))
        os.cp("RandX_Cpp17.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <RandX.hpp>
            #include <cstdint>
            static void test() {
                std::uint64_t v = RandX::RandInt<std::uint64_t>(0, 1000);
                (void)v;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
