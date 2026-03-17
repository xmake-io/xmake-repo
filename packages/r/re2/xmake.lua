package("re2")
    set_homepage("https://github.com/google/re2")
    set_description("RE2 is a fast, safe, thread-friendly alternative to backtracking regular expression engines like those used in PCRE, Perl, and Python. It is a C++ library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/re2.git", {alias = "git"})
    add_urls("https://github.com/google/re2/archive/refs/tags/$(version).tar.gz", {version = function (version) return version:gsub("%.", "-") end})

    add_versions("2020.11.01", "8903cc66c9d34c72e2bc91722288ebc7e3ec37787ecfef44d204b2d6281954d7")
    add_versions("2021.06.01", "26155e050b10b5969e986dab35654247a3b1b295e0532880b5a9c13c0a700ceb")
    add_versions("2021.08.01", "cd8c950b528f413e02c12970dce62a7b6f37733d7f68807e73a2d9bc9db79bc8")
    add_versions("2021.11.01", "8c45f7fba029ab41f2a7e6545058d9eec94eef97ce70df58e92d85cfc08b4669")
    add_versions("2022.02.01", "9c1e6acfd0fed71f40b025a7a1dabaf3ee2ebb74d64ced1f9ee1b0b01d22fd27")
    add_versions("2023.11.01", "4e6593ac3c71de1c0f322735bc8b0492a72f66ffccfad76e259fa21c41d27d8a")
    add_versions("2024.03.01", "7b2b3aa8241eac25f674e5b5b2e23d4ac4f0a8891418a2661869f736f03f57f4")
    add_versions("2024.04.01", "3f6690c3393a613c3a0b566309cf04dc381d61470079b653afc47c67fb898198")
    add_versions("2024.06.01", "7326c74cddaa90b12090fcfc915fe7b4655723893c960ee3c2c66e85c5504b6c")
    add_versions("2024.07.02", "eb2df807c781601c14a260a507a5bb4509be1ee626024cb45acbd57cb9d4032b")
    add_versions("2025.07.17", "41bea2a95289d112e7c2ccceeb60ee03d54269e7fe53e3a82bab40babdfa51ef")
    add_versions("2025.08.12", "2f3bec634c3e51ea1faf0d441e0a8718b73ef758d7020175ed7e352df3f6ae12")
    add_versions("2025.11.05", "87f6029d2f6de8aa023654240a03ada90e876ce9a4676e258dd01ea4c26ffd67")

    add_versions("git:2025.07.17", "2025-07-17")
    add_versions("git:2025.08.12", "2025-08-12")
    add_versions("git:2025.11.05", "2025-11-05")

    add_deps("cmake", "abseil <=20260107.0")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        local version = package:version()
        if version and version:ge("2024.06.01") and package:is_plat("mingw") then
            package:add("syslinks", "dbghelp")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DRE2_BUILD_TESTING=OFF",
            "-DCMAKE_CXX_STANDARD=" .. package:dep("abseil"):config("cxx_standard"),
        }

        local absl_dir = ""
        local abseil = package:dep("abseil"):fetch()
        if abseil then
            for _, linkdir in ipairs(abseil.linkdirs) do
                local dir = path.join(linkdir, "cmake", "absl")
                if os.isdir(dir) then
                    absl_dir = dir
                    break
                end
            end
        end
        table.insert(configs, "-Dabsl_DIR=" .. absl_dir)

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {packagedeps = {"abseil"}}
        if package:has_tool("cxx", "cl", "clang_cl") then
            opt.cxflags = {"/EHsc"}
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <cassert>
            void test() {
                int i;
                std::string s;
                assert(RE2::FullMatch("ruby:1234", "(\\w+):(\\d+)", &s, &i));
                assert(s == "ruby");
                assert(i == 1234);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "re2/re2.h"}))
    end)
