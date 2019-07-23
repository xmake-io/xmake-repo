package("boost")

    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")

    add_urls("https://dl.bintray.com/boostorg/release/$(version).tar.bz2", {version = function (version) 
            return version .. "/source/boost_" .. (version:gsub("%.", "_"))
        end})
    add_urls("https://github.com/xmake-mirror/boost/releases/download/boost-$(version).tar.bz2", {version = function (version) 
            return version .. "/boost_" .. (version:gsub("%.", "_"))
        end})
    add_versions("1.70.0", "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778")

    if is_plat("linux") then
        add_deps("bzip2", "zlib")
    end

    local libnames = {"filesystem", 
                      "fiber", 
                      "coroutine", 
                      "context", 
                      "thread", 
                      "regex",
                      "system",
                      "container",
                      "exception",
                      "timer",
                      "atomic",
                      "graph",
                      "serialization",
                      "random",
                      "wave",
                      "date_time",
                      "locale",
                      "iostreams"}

    add_configs("multi",        { description = "Enable multi-thread support.",  default = true, type = "boolean"})
    for _, libname in ipairs(libnames) do
        add_configs(libname,    { description = "Enable " .. libname .. " library.", default = (libname == "filesystem"), type = "boolean"})
    end

    on_load("windows", function (package)
        local vs_runtime = package:config("vs_runtime")
        for _, libname in ipairs(libnames) do
            local linkname = "libboost_" .. libname
            if package:config("multi") then
                linkname = linkname .. "-mt"
            end
            if vs_runtime == "MT" then
                linkname = linkname .. "-s"
            elseif vs_runtime == "MTd" then
                linkname = linkname .. "-sgd"
            elseif vs_runtime == "MDd" then
                linkname = linkname .. "-gd"
            end
            package:add("links", linkname)
        end
    end)

    on_install("macosx", "linux", "windows", function (package)
    
        -- force boost to compile with the desired compiler
        local file = io.open("user-config.jam", "a")
        if file then
            if is_plat("macosx") then
                file:print("using darwin : : %s ;", package:build_getenv("cxx"))
            elseif is_plat("windows") then
                file:print("using msvc : : %s ;", package:build_getenv("cxx"))
            else
                file:print("using gcc : : %s ;", package:build_getenv("cxx"))
            end
            file:close()
        end

        local bootstrap_argv = 
        {
            "--prefix=" .. package:installdir(), 
            "--libdir=" .. package:installdir("lib"),
            "--without-icu"
        }
        if is_host("windows") then
            os.vrunv("bootstrap.bat", bootstrap_argv)
        else
            os.vrunv("./bootstrap.sh", bootstrap_argv)
        end
        os.vrun("./b2 headers")

        local argv =
        {
            "--prefix=" .. package:installdir(), 
            "--libdir=" .. package:installdir("lib"), 
            "-d2",
            "-j4",
            "--hash",
            "--layout=tagged-1.66",
            "--user-config=user-config.jam",
            "--no-cmake-config",
            "-sNO_LZMA=1",
            "-sNO_ZSTD=1",
            "install",
            "threading=" .. (package:config("multi") and "multi" or "single"),
            "debug-symbols=" .. (package:debug() and "on" or "off"),
            "link=static"
        }
        local arch = package:arch()
        if arch == "x64" or arch == "x86_64" then
            table.insert(argv, "address-model=64")
        else
            table.insert(argv, "address-model=32")
        end
        if package:plat() == "windows" then
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime and vs_runtime:startswith("MT") then
                table.insert(argv, "runtime-link=static")
            else
                table.insert(argv, "runtime-link=shared")
            end
            table.insert(argv, "cxxflags=-std:c++14")
        else
            table.insert(argv, "cxxflags=-std=c++14")
        end
        for _, libname in ipairs(libnames) do
            if package:config(libname) then
                table.insert(argv, "--with-" .. libname)
            end
        end
        os.vrunv("./b2", argv)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/algorithm/string.hpp>
            #include <string>
            #include <vector>
            #include <assert.h>
            using namespace boost::algorithm;
            using namespace std;
            static void test() {
                string str("a,b");
                vector<string> strVec;
                split(strVec, str, is_any_of(","));
                assert(strVec.size()==2);
                assert(strVec[0]=="a");
                assert(strVec[1]=="b");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
