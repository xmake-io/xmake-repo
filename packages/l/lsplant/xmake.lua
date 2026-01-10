package("lsplant")
    set_homepage("https://lsposed.org/LSPlant/")
    set_description("A hook framework for Android Runtime (ART)")

    add_urls("https://github.com/LSPosed/LSPlant.git", {submodules = false})

    add_versions("2025.11.28", "30647309ced1d70385c7e93fd41602102dd4a2f8")

    add_deps("dexbuilder")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <string_view>
                #include <cstddef>
                void test() {
                    constexpr auto lambda_check = [](std::string_view a) { return a.empty(); };
                    int data[2] = {1, 2};
                    auto [x, y] = data;
                    auto dex_idx = 0zu; 
                }
            ]]}, {configs = {languages = "c++23"}}), "package(lsplant) Require at least C++23 (supports '0zu' suffix).")
        end)
    end

    on_install("android", function (package)
        os.cd("lsplant/src/main/jni")
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c++23")

            add_requires("dexbuilder")
            add_packages("dexbuilder")

            target("lsplant")
                set_kind("$(kind)")
                add_files(
                    "**.cc",
                    "**.cxx")
                add_headerfiles("include/(**.hpp)",
                                "include/(**.ixx)")
                add_includedirs(".", {public = true})
                add_includedirs("include", {public = true})
                add_syslinks("log")
                set_policy("build.c++.modules", true)
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <lsplant.hpp>
            void test() {
                JNIEnv env;
                InitInfo info;
                lsplant::v2::Init(&env, info);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
