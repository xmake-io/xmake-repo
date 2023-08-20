package("clean-test")
    set_homepage("https://clean-test.dev")
    set_description("A modern C++-20 testing framework.")
    set_license("BSL-1.0")

    add_urls("https://github.com/clean-test/clean-test.git")
    add_versions("2023.05.15", "d99321c97ba51c26397114ce535be4d1d9174693")

    if is_plat("linux") then
        add_syslinks("pthread")
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    elseif is_plat("macosx", "iphoneos") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DCLEANTEST_TEST=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DCLEANTEST_BUILD_STATIC=OFF")
            table.insert(configs, "-DCLEANTEST_BUILD_SHARED=ON")
        else
            table.insert(configs, "-DCLEANTEST_BUILD_STATIC=ON")
            table.insert(configs, "-DCLEANTEST_BUILD_SHARED=OFF")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <clean-test/clean-test.h>
            constexpr auto sum(auto... vs) { return (0 + ... + vs); }
            namespace ct = clean_test;
            using namespace ct::literals;
            void test() {
                auto const suite = ct::Suite{"sum", [] {
                    "0"_test = [] { ct::expect(sum() == 0_i); };
                }};
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
