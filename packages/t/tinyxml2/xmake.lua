package("tinyxml2")

    set_homepage("http://www.grinninglizard.com/tinyxml2/")
    set_description("simple, small, efficient, C++ XML parser that can be easily integrating into other programs.")

    add_urls("https://github.com/leethomason/tinyxml2/archive/8.0.0.tar.gz")
    add_urls("https://github.com/leethomason/tinyxml2.git")
    add_versions("8.0.0", "6ce574fbb46751842d23089485ae73d3db12c1b6639cda7721bf3a7ee862012c")

    on_install("linux", "macosx", "windows", function (package)
        local config = {}

        table.insert(config, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(config, "-DBUILD_TESTS=OFF")

        import("package.tools.cmake").install(package, config)
    end)

    on_install("mingw", "android", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinyxml2")
                set_kind("$(kind)")
                add_headerfiles("tinyxml2.h")
                add_files("tinyxml2.cpp")
        ]])

        import("package.tools.xmake").install(package, {kind = package:config("shared")  and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                static const char* xml = "<element/>";
                tinyxml2::XMLDocument doc;
                doc.Parse(xml);
            }
        ]]}, {includes = "tinyxml2.h"}))
    end)