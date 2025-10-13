package("microsoft-proxy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/proxy")
    set_description("Proxy: Easy Polymorphism in C++")
    set_license("MIT")

    add_urls("https://github.com/microsoft/proxy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/proxy.git")

    add_versions("4.0.1", "78e1d88c36d2e7ee8f8dc47f112cdb96b8838dfd4177e104b53d9b64ed9b2357")
    add_versions("4.0.0", "b51f07f315a3cd7ecfbbaa86fa8fae2b9bc99c148c16f41cddd9c06dcb8eb58b")
    add_versions("3.4.0", "ca13bdc2b67a246a22ccda43690345daeb25bc3bb5c2c3ed1f6e4e466e9361aa")
    add_versions("3.3.0", "9a5e89e70082cbdd937e80f5113f4ceb47bf6361cf7b88cb52782906a1b655cc")
    add_versions("3.2.1", "83df61c6ef762df14b4f803a1dde76c6e96261ac7f821976478354c0cc2417a8")
    add_versions("3.2.0", "a828432a43a1e05c65176e58b48a6d6270669862adb437a069693f346275b5f0")
    add_versions("3.1.0", "c86ed7767ed3e90250632f2b5269c83225b0ae986314c58596d421b245f26cd1")
    add_versions("3.0.0", "7e073e217e5572bc4c17ed5893273c80ea34c87e1406c853beeb9ca9bdda9733")
    add_versions("2.4.0", "7eed973655938d681a90dcc0c200e6cc1330ea8611a9c1a9e1b30439514443cb")
    add_versions("2.3.0", "ff6f17c5360895776d29ce2b1235de7b42912468b52729810506431e352a78d0")
    add_versions("2.2.1", "096f0b2d793dffc54d41def2bca0ced594b6b8efe35ac5ae27db35802e742b96")
    add_versions("1.1.1", "6852b135f0bb6de4dc723f76724794cff4e3d0d5706d09d0b2a4f749f309055d")

    add_configs("cmake", {description = "Use cmake buildsystem", default = true, type = "boolean"})

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") then
                if package:version() and package:version():ge("3.0.0") then
                    import("core.base.semver")

                    local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                    assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(microsoft-proxy): need vs_toolset >= v143")
                end
            elseif package:is_plat("android") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(microsoft-proxy) require ndk version > 22")
            end

            assert(package:check_cxxsnippets({test = [[
                #include <format>
                void test(std::format_context& ctx) {}
            ]]}, {configs = {languages = "c++20"}}), "package(microsoft-proxy) Require at least C++20.")
        end)
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DBUILD_TESTING=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            import("package.tools.cmake").install(package, configs)
        else
            if package:version() and package:version():le("3.3.0") then
                os.vcp("proxy.h", package:installdir("include"))
            else
                -- version > 3.3.0, copy the entire 'repo/include' folder into 'include'
                -- for downstream cmake compability.
                os.vcp("include/*", package:installdir("include"))
            end
        end
    end)

    on_test(function (package)
        if package:version() and package:version():le("3.3.0") and not package:config("cmake") then
            assert(package:has_cxxincludes("proxy.h", {configs = {languages = "c++20"}}))
        else
            assert(package:has_cxxincludes("proxy/proxy.h", {configs = {languages = "c++20"}}))
        end
    end)
