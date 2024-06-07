package("cgraph")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.chunel.cn")
    set_description("A common used C++ DAG framework")
    set_license("MIT")

    add_urls("https://github.com/ChunelFeng/CGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChunelFeng/CGraph.git")

    add_versions("v2.5.4", "fd5a53dc0d7e3fc11050ccc13fac987196ad42184a4e244b9d5e5d698b1cb101")

    if is_plat("windows") then
        add_cxxflags("/source-charset:utf-8")
    end

    on_install(function (package)
        os.vcp("src/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <CGraph.h>
            class MyNode1 : public CGraph::GNode {
            public:
                CStatus run() override {
                    CGRAPH_SLEEP_SECOND(1)
                    return CStatus();
                }
            };
            void test() {}
        ]]}, {configs = {languages = "c++11"}}))
    end)
