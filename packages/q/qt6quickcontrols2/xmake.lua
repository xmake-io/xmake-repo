package("qt6quickcontrols2")
    set_base("qt6lib")
    set_kind("library")

    on_load(function (package)
        package:add("deps", "qt6quick", "qt6qml", "qt6gui", "qt6core", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "QuickControls2")

        package:base():script("load")(package)
    end)

    on_test(function (package)
        local cxflags
        if package:is_plat("windows") then
            cxflags = {"/Zc:__cplusplus", "/permissive-"}
        else
            cxflags = "-fPIC"
        end
        
        assert(package:check_cxxsnippets({test = [[
            void test() {
                QQuickStyle::setStyle("Material");
            }
        ]]}, {
            configs = {languages = "c++17", cxflags = cxflags}, 
            includes = {"QQuickStyle"}
        }))
    end)
