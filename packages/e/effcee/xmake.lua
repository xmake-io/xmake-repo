package("effcee")

    set_homepage("https://github.com/google/effcee")
    set_description("Effcee is a C++ library for stateful pattern matching of strings.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/effcee/archive/v$(version).tar.gz")
    add_versions("2019.1", "0c49849859d356f39273fa01f674eaf687fd5e5fe83c94510784c2279bfb793d")

    add_deps("cmake")
    add_deps("re2")

    on_install("macosx", "linux", "windows", function (package)
        io.gsub(path.join("cmake", "setup_build.cmake"), "find_host_package%(", "#")
        io.gsub("CMakeLists.txt", "add_subdirectory%(third_party%)", "#")
        local configs = {"-DEFFCEE_BUILD_SAMPLES=OFF", "-DEFFCEE_BUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DEFFCEE_ENABLE_SHARED_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "re2"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto opt = effcee::Options().SetChecksName("checks");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "effcee/effcee.h"}))
    end)
