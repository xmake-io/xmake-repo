package("imguitextselect")
    set_homepage("https://github.com/AidanSun05/ImGuiTextSelect")
    set_description("Text selection implementation for Dear ImGui")
    set_license("MIT")

    add_urls("https://github.com/AidanSun05/ImGuiTextSelect/archive/v$(version).tar.gz",
             "https://github.com/AidanSun05/ImGuiTextSelect.git")

    add_versions("1.3.0", "529cf6bf5dc80d7540083395f93dd2a075e9c71450eb140104944021156a8dfa")
    add_versions("1.2.0", "63af906b955c8160b350aff426f7f89e6a250a7b784933338d1fc9504ac3a9ac")
    add_versions("1.1.6", "41ebb4323697bd2e1bedd3bb52a5abd222e941b9e145896d25741143b31ecec7")
    add_versions("1.1.5", "43636bc5a52c0ed92414d34976a839fcb69f76246e9c729c9d9e0da2c53d57b2")
    add_versions("1.1.4", "a8bb58662dd35937ee098652ebb2a29d63ed9c2383d60c54fd00a2a9168fe5e3")
    add_versions("1.1.3", "cd8b4720ca71dc4ab87ca9b860ce507c34feaef1846456b89fd8827c0d259f70")
    add_versions("1.1.2", "2e15853e97710f02be9fdb64fd2f2ad495e88f844ce5e8a14d63b86d9f2e7b6c")
    add_versions("1.1.1", "ed36cb7bdbe248a5e0d9f73977b24eeb14d051dd385b273d25e4617aac303c29")
    add_versions("1.1.0", "9464f5cdd118a77ecd64c21cad713ed4a729bae742750feb980d7c36e787d317")
    add_versions("1.0.0", "198184dc562a868e748606e1b88c708491f04762413ddcb2d2a251a1cba38a43")

    add_deps("imgui")

    on_load(function (package)
        local version = package:version()
        if version and version:lt("1.3.0") then
            package:add("deps", "utfcpp")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local version = package:version()
        local configs = {
            utfcpp = version and version:lt("1.3.0")
        }

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cstddef>
            #include <string_view>
            #include <textselect.hpp>
            void test() {
                auto getLineAtIdx = [](std::size_t) { return std::string_view{}; };
                auto getNumLines = []() { return (std::size_t)0; };
                TextSelect textSelect{ getLineAtIdx, getNumLines };
                textSelect.update();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
