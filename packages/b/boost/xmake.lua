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

    add_configs("multi",         { description = "Enable multi-thread support.",  default = true, type = "boolean"})
    add_configs("filesystem",    { description = "Enable filesystem library.",    default = true, type = "boolean"})
    add_configs("fiber",         { description = "Enable fiber library.",         default = false, type = "boolean"})
    add_configs("coroutine",     { description = "Enable coroutine library.",     default = false, type = "boolean"})
    add_configs("context",       { description = "Enable context library.",       default = false, type = "boolean"})
    add_configs("thread",        { description = "Enable thread library.",        default = false, type = "boolean"})
    add_configs("regex",         { description = "Enable regex library.",         default = false, type = "boolean"})
    add_configs("system",        { description = "Enable system library.",        default = false, type = "boolean"})
    add_configs("container",     { description = "Enable container library.",     default = false, type = "boolean"})
    add_configs("exception",     { description = "Enable exception library.",     default = false, type = "boolean"})
    add_configs("timer",         { description = "Enable timer library.",         default = false, type = "boolean"})
    add_configs("atomic",        { description = "Enable atomic library.",        default = false, type = "boolean"})
    add_configs("graph",         { description = "Enable graph library.",         default = false, type = "boolean"})
    add_configs("serialization", { description = "Enable serialization library.", default = false, type = "boolean"})
    add_configs("random",        { description = "Enable random library.",        default = false, type = "boolean"})
    add_configs("wave",          { description = "Enable wave library.",          default = false, type = "boolean"})
    add_configs("date_time",     { description = "Enable date time library.",     default = false, type = "boolean"})
    add_configs("locale",        { description = "Enable locale library.",        default = false, type = "boolean"})
    add_configs("iostreams",     { description = "Enable iostreams library.",     default = false, type = "boolean"})

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
        local libs = {}
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
        for _, libname in ipairs(libnames) do
            if package:config(libname) then
                table.insert(libs, libname)
            end
        end
        if #libs > 0 then
            table.insert(bootstrap_argv, "--with-libraries=" .. table.concat(libs, ","))
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
        local arch = package:arch()
        if arch == "x64" or arch == "x86_64" then
            table.insert(argv, "address-model=64")
        else
            table.insert(argv, "address-model=32")
        end
        table.insert(argv, "debug-symbols=" .. (package:debug() and "on" or "off"))
        if is_host("windows") then
            os.vrunv("bootstrap.bat", bootstrap_argv)
        else
            os.vrunv("./bootstrap.sh", bootstrap_argv)
        end
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
