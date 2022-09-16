package("wil")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/wil")
    set_description("The Windows Implementation Libraries (WIL) is a header-only C++ library created to make life easier for developers on Windows through readable type-safe C++ interfaces for common Windows coding patterns.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/wil.git")
    add_versions("2022.09.16", "5f4caba4e7a9017816e47becdd918fcc872039ba")

    add_deps("cmake")
    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto foo = GetModuleInstanceHandle();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "wil/win32_helpers.h"}))
    end)
