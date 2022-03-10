package("qt5core")
    set_base("qt5lib")
    
    on_load(function (package)
        package:add("deps", "qt5base", {debug = package:is_debug(), version = package:version_str()})
        package:data_set("libname", "Core")
        if package:is_plat("android") then
            package:data_set("syslinks", "z")
        elseif package:is_plat("iphoneos") then
            package:data_set("frameworks", {"UIKit", "CoreText", "CoreGraphics", "CoreServices", "CoreFoundation"})
            package:data_set("links", "qtharfbuzz")
            package:data_set("syslinks", {"qtpcre2", "z"})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QCoreApplication app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = not package:is_plat("windows") and "-fPIC" or nil}, includes = {"QCoreApplication"}}))
    end)
