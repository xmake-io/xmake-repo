package("swxjson")
    set_homepage("https://github.com/swxlion/swxJson")
    set_description("A easy to use & convenient JSON library for C++11.")
    set_license("MIT")

    add_urls("https://github.com/swxlion/swxJson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/swxlion/swxJson.git")

    add_versions("v1.0.9", "672c9362a13a53628469e2d7bb5cc6c976e1fa52c730ae95945c9509b0263f01")
    add_patches("v1.0.9", "patches/fix.diff", "99eb96c1b51ad2a216289d6011ddc980cb7f55be941e4f531584c12ace712738")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("swxjson")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_headerfiles("src/(*.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <swxJson.h>
            using namespace swxJson;
            void test() {
                const std::string dictDemo = R"({"strDict":{"123":"aa", "456":"bb", "789":"cc"}, "intDict":{"aa":1, "bb":2, "cc":3, "dd":4, "ee":5}})";
                JsonPtr json = Json::parse(dictDemo.c_str());
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
