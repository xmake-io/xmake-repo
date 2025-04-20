package("cppjieba")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/yanyiwu/cppjieba")
    set_description([["结巴"中文分词的C++版本]])
    set_license("MIT")

    add_urls("https://github.com/yanyiwu/cppjieba/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yanyiwu/cppjieba.git", {submodules = false})

    add_versions("v5.4.1", "ee5b542dfd24713256e612588f0f2fbecba802c324da6cd2231792c02f9c062c")
    add_versions("v5.4.0", "6358e7f961e601ee6a01ce968bd07dad4e455a2c8721520d0304cc94b2d029ee")
    add_versions("v5.2.0", "00c420e9e1b212827a38b6e252468895f744c0e7be8c4feaab4e0a93b8d3b1ca")

    add_deps("limonp")

    on_install(function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/utf-8")
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                cppjieba::Jieba jieba("DICT_PATH", "HMM_PATH", "USER_DICT_PATH", "IDF_PATH", "STOP_WORD_PATH");
            }
        ]]}, {configs = {languages = "c++14"}, includes = "cppjieba/Jieba.hpp"}))
    end)
