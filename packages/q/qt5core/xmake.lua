package("qt5core")
    set_base("qt5lib")
    set_kind("library")

    on_load(function (package)
        package:data_set("libname", "Core")
        if package:is_plat("android") then
            package:data_set("syslinks", "z")
        elseif package:is_plat("iphoneos") then
            package:data_set("frameworks", {"UIKit", "CoreText", "CoreGraphics", "CoreServices", "CoreFoundation"})
            package:data_set("syslinks", {"qtpcre2", "z"})
        end

        package:base():script("load")(package)
    end)

    on_test(function (package)
        local cxflags
        if not package:is_plat("windows") then
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QCoreApplication app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}, includes = {"QCoreApplication"}}))
    end)
