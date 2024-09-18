package("flux")
    set_kind("library", {headeronly = true})
    set_homepage("https://tristanbrindle.com/flux/")
    set_description("A C++20 library for sequence-orientated programming")
    set_license("BSL-1.0")

    add_urls("https://github.com/tcbrindle/flux/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tcbrindle/flux.git")

    add_versions("v0.4.0", "95e7d9d71c9ee9e89bb24b46ccba77ddfb0a1580630c2faab0b415dacc7c8d56")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndkver = ndk:config("ndkver")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndkver and tonumber(ndkver) > 22, "package(flux) require ndk version > 22")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(flux) require ndk api >= 24")
        end)

        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(flux) require vs_toolset >= 14.3")
            end
        end)
    end

    on_install(function (package)
        local configs = {"-DFLUX_BUILD_EXAMPLES=OFF", "-DFLUX_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <flux.hpp>
            void test() {
                constexpr auto result = flux::from(std::array{1, 2, 3, 4, 5})
                         .filter(flux::pred::even)
                         .map([](int i) { return i * 2; })
                         .sum();
                static_assert(result == 12);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
