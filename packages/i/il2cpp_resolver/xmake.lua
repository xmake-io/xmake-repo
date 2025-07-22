package("il2cpp_resolver")
    set_kind("library", {headeronly = true})
    set_homepage("https://sneakyevil.gitbook.io/il2cpp-resolver/")
    set_description("A run-time API resolver for IL2CPP Unity.")
    set_license("Unlicense")

    add_urls("https://github.com/sneakyevil/IL2CPP_Resolver.git")
    add_versions("2024.07.30", "251051e4f2f6b2b6f3a8169d65f3739317e1de08")

    on_install("windows", function (package)
        os.cp("*.hpp", package:installdir("include"))
        os.cp("API/**.hpp", package:installdir("include/API"), {rootdir = "API"})
        os.cp("Unity/**.hpp", package:installdir("include/Unity"), {rootdir = "Unity"})
        os.cp("Utils/**.hpp", package:installdir("include/Utils"), {rootdir = "Utils"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <IL2CPP_Resolver.hpp>
            void test() {
                auto init = IL2CPP::Initialize();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
