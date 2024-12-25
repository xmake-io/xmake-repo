package("cgraph")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.chunel.cn")
    set_description("A common used C++ DAG framework")
    set_license("MIT")

    add_urls("https://github.com/ChunelFeng/CGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChunelFeng/CGraph.git")

    add_versions("v2.6.2", "7067ed97b8c4ad118dccc93aca58e739717d87bcd21d6ea937ffe2e2bd45706d")
    add_versions("v2.6.1", "0024854adfa836d424ff38782c926173f2d869af205c39a031cf0dc13c418c84")
    add_versions("v2.6.0", "1b055ee86f0340f2c35b4ed40c4a3b4cc05081b115b0fb634d778671018648f2")
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
