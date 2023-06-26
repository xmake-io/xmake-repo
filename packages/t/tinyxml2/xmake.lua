package("tinyxml2")

    set_homepage("http://www.grinninglizard.com/tinyxml2/")
    set_description("simple, small, efficient, C++ XML parser that can be easily integrating into other programs.")

    add_urls("https://github.com/leethomason/tinyxml2/archive/$(version).tar.gz")
    add_urls("https://github.com/leethomason/tinyxml2.git")
    add_versions("8.0.0", "6ce574fbb46751842d23089485ae73d3db12c1b6639cda7721bf3a7ee862012c")
    add_versions("9.0.0", "cc2f1417c308b1f6acc54f88eb70771a0bf65f76282ce5c40e54cfe52952702c")

    if is_plat("linux", "macosx", "windows") then
        add_deps("cmake")
    end

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("mingw", "android", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinyxml2")
                set_kind("$(kind)")
                set_languages("cxx11")
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
        ]]}, {configs = {languages = "c++11"}, includes = "tinyxml2.h"}))
    end)
