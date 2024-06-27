package("11zip")
    set_homepage("https://github.com/Sygmei/11Zip")
    set_description("Dead simple zipping / unzipping C++ Lib")
    set_license("MIT")

    add_urls("https://github.com/Sygmei/11Zip/archive/516e161d5c96aa8f2603fb30b10b7770a87332c2.tar.gz",
             "https://github.com/Sygmei/11Zip.git")

    add_versions("2023.05.10", "9e4052571c73ecd8e328fa9e8399f606604baa3373103d2e7dddb75019330ee0")
    
    add_includedirs("include", "include/elzip")

    add_deps("minizip-ng")

    on_install("macosx", "android", "linux", "windows", "mingw", function (package)
        io.replace("src/unzipper.cpp", "unzLocateFile(zipFile_, filename.data(), nullptr)", "unzLocateFile(zipFile_, filename.data(), 0)", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::string zipname;
                elz::extractZip(zipname);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "elzip/elzip.hpp"}))
    end)
