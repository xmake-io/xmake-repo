package("mecab")
    set_description("Yet another part-of-speech and morphological analyzer.")
    set_homepage("https://taku910.github.io/mecab/")
    set_license("GPL-2.0")
    add_urls("https://github.com/taku910/mecab/archive/05481e751dd5aa536a2bace46715ce54568b972a.zip")
    add_versions("0.996", "d5d3ec4954e969ea93f4f1d778d7dc3ae98848056ee1c8cb99fced8578fd73f3")
    if is_plat("linux") then
        add_extsources("pacman::mecab-git", "apt::mecab")
    end
    on_install("macosx", "linux", function (package)
        os.cd("mecab")
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, {"--with-charset=utf-8"})
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mecab.h>
            static void test() {
                std::unique_ptr<MeCab::Tagger> tagger{ MeCab::createTagger() };
                assert(tagger != nullptr);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
