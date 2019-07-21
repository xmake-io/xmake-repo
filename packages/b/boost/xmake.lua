package("boost")

    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")

    add_urls("https://dl.bintray.com/boostorg/release/$(version).tar.bz2", {version = function (version) 
            return version .. "/source/boost_" .. (version:gsub("%.", "_"))
        end})
    add_versions("1.70.0", "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778")

    if is_plat("linux") then
        add_deps("bzip2", "zlib")
    elseif is_plat("macosx") then
        add_deps("icu4c")
    end

    add_configs("multi", { description = "Enable multi-thread support.", default = true, type = "boolean"})

    on_install("macosx", "linux", function (package)
    
        -- force boost to compile with the desired compiler
        local file = io.open("user-config.jam", "a")
        if file then
            if is_plat("macosx") then
                file:print("using darwin : : %s ;", package:build_getenv("cxx"))
            else
                file:print("using gcc : : %s ;", package:build_getenv("cxx"))
            end
            file:close()
        end

        local bootstrap_argv = 
        {
            "--prefix=" .. package:installdir(), 
            "--libdir=" .. package:installdir("lib"), 
            "--without-libraries=python,mpi,log"
        }
        local icu4c = package:dep("icu4c")
        if icu4c then
            table.insert(bootstrap_argv, "--with-icu=" .. icu4c:installdir())
        else
            table.insert(bootstrap_argv, "--without-icu")
        end
        local argv =
        {
            "--prefix=" .. package:installdir(), 
            "--libdir=" .. package:installdir("lib"), 
            "-d2",
            "-j4",
            "--layout=tagged-1.66",
            "--user-config=user-config.jam",
            "--no-cmake-config",
            "-sNO_LZMA=1",
            "-sNO_ZSTD=1",
            "install",
            "threading=" .. (package:config("multi") and "multi" or "single"),
            "link=static",
            "cxxflags=-std=c++14"
        }
        os.vrunv("./bootstrap.sh", bootstrap_argv)
        os.vrun("./b2 headers")
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
