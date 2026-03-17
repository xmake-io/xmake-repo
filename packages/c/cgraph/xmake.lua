package("cgraph")
    set_homepage("http://www.chunel.cn")
    set_description("A common used C++ DAG framework")
    set_license("MIT")

    add_urls("https://github.com/ChunelFeng/CGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChunelFeng/CGraph.git")

    add_versions("v3.2.2", "6533e8772389f50459d33db764ebee6d0d530e30f5921d95572d030463122cdd")
    add_versions("v3.1.2", "c3825c846b408a2e8def308ba0688a43baddedd1674ede84c955dc33a5847bf0")
    add_versions("v3.1.1", "b49014b1774ed4009a8770ce482e5cb260ee2cbf7854d7795af0812ccecf48ea")
    add_versions("v3.1.0", "fc2c2df5a975a77eafa1ce396a2e2aa36b8498af15e991c8ce964e1a3b39df73")
    add_versions("v2.6.2", "7067ed97b8c4ad118dccc93aca58e739717d87bcd21d6ea937ffe2e2bd45706d")
    add_versions("v2.6.1", "0024854adfa836d424ff38782c926173f2d869af205c39a031cf0dc13c418c84")
    add_versions("v2.6.0", "1b055ee86f0340f2c35b4ed40c4a3b4cc05081b115b0fb634d778671018648f2")
    add_versions("v2.5.4", "fd5a53dc0d7e3fc11050ccc13fac987196ad42184a4e244b9d5e5d698b1cb101")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/utf-8")
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            set_encodings("utf-8")
            target("cgraph")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_headerfiles("src/(**.h)", "src/(**.inl)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                if is_plat("linux", "macosx") then
                    add_defines("_ENABLE_LIKELY_")
                end
                if is_plat("linux", "bsd") then
                    add_syslinks("pthread")
                end
        ]])
        import("package.tools.xmake").install(package)
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
