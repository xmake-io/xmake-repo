package("boost")

    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")

    add_urls("https://dl.bintray.com/boostorg/release/$(version).tar.bz2", {version = function (version)
            return version .. "/source/boost_" .. (version:gsub("%.", "_"))
        end})
    add_urls("https://github.com/xmake-mirror/boost/releases/download/boost-$(version).tar.bz2", {version = function (version)
            return version .. "/boost_" .. (version:gsub("%.", "_"))
        end})

    add_versions("1.74.0", "83bfc1507731a0906e387fc28b7ef5417d591429e51e788417fe9ff025e116b1")
    add_versions("1.73.0", "4eb3b8d442b426dc35346235c8733b5ae35ba431690e38c6a8263dce9fcbb402")
    add_versions("1.72.0", "59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722")
    add_versions("1.70.0", "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778")

    if is_plat("linux") then
        add_deps("bzip2", "zlib")
    elseif is_plat("windows") then
        add_cxflags("/EHsc")
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
            local linkname = (package:config("shared") and "boost_" or "libboost_") .. libname
            if package:config("multi") then
                linkname = linkname .. "-mt"
            end
            if package:config("shared") then
                if package:debug() then
                    linkname = linkname .. "-gd"
                end
            elseif vs_runtime == "MT" then
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
                -- we uses ld/clang++ for link stdc++ for shared libraries
                file:print("using darwin : : %s ;", package:build_getenv("ld"))
            elseif is_plat("windows") then
                file:print("using msvc : : %s ;", os.args(package:build_getenv("cxx")))
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
            "-sNO_LZMA=1",
            "-sNO_ZSTD=1",
            "install",
            "threading=" .. (package:config("multi") and "multi" or "single"),
            "debug-symbols=" .. (package:debug() and "on" or "off"),
            "link=" .. (package:config("shared") and "shared" or "static")
        }
        if package:is_arch("x64", "x86_64") then
            table.insert(argv, "address-model=64")
        else
            table.insert(argv, "address-model=32")
        end
        if package:is_plat("windows") then
            local vs_runtime = package:config("vs_runtime")
            if package:config("shared") then
                table.insert(argv, "runtime-link=shared")
            elseif vs_runtime and vs_runtime:startswith("MT") then
                table.insert(argv, "runtime-link=static")
            else
                table.insert(argv, "runtime-link=shared")
            end
            table.insert(argv, "cxxflags=-std:c++14")
        else
            table.insert(argv, "cxxflags=-std=c++14")
            if package:build_getenv("cxx"):find("clang", 1, true) then
                table.insert(argv, "cxxflags=-stdlib=libc++")
                table.insert(argv, "linkflags=-stdlib=libc++")
            end
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
