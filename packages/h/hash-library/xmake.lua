package("hash-library")
    set_homepage("https://create.stephan-brumme.com/hash-library/")
    set_description("Portable C++ hashing library")
    set_license("zlib")

    add_urls("https://github.com/stbrumme/hash-library.git")
    add_versions("2021.09.29", "d389d18112bcf7e4786ec5e8723f3658a7f433d7")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("hash-library")
               set_kind("$(kind)")
               add_files("*.cpp")
               add_headerfiles("(*.h)")
               if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
               end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        for _, sourcefile in ipairs(os.files("*.cpp")) do
            io.replace(sourcefile, "#include <endian.h>", "", {plain = true})
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <iostream>
            void test() {
                SHA1 sha1;
                std::string myHash  = sha1("Hello World");
                std::cout << myHash << std::endl;
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"sha1.h"}}))
    end)
