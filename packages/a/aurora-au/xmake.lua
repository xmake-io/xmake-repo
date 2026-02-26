package("aurora-au")
    set_kind("library", {headeronly = true})
    set_homepage("https://aurora-opensource.github.io/au")
    set_description("A C++14-compatible physical units library with no dependencies and a single-file delivery option. Emphasis on safety, accessibility, performance, and developer experience.")
    set_license("Apache-2.0")

    set_urls("https://github.com/aurora-opensource/au/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aurora-opensource/au.git")

    add_versions("0.5.1", "65675096bab253f81813760a5643810cb60c662a4fb2944bb49d77d9c11c85e8")
    add_versions("0.5.0", "69d3510df7880dc5a109d751b8afc38b2adbf4af2e829b569b19cbdd970fee5e")
    add_versions("0.4.1", "5e88a0ffcb0a0843f4bd4d4ea4429c793f85dfcb8c1e7f7978de6fecab739b84")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DAU_ENABLE_TESTING=OFF", "-DAU_EXCLUDE_GTEST_DEPENDENCY=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                constexpr auto length = au::meters(100.0);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "au/units/meters.hh"}))
    end)
