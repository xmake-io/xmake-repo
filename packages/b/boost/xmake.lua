package("boost")

    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")

    add_urls("https://boostorg.jfrog.io/artifactory/main/release/$(version).tar.bz2", {version = function (version)
            return version .. "/source/boost_" .. (version:gsub("%.", "_"))
        end})
    add_urls("https://github.com/xmake-mirror/boost/releases/download/boost-$(version).tar.bz2", {version = function (version)
            return version .. "/boost_" .. (version:gsub("%.", "_"))
        end})
    add_versions("1.76.0", "f0397ba6e982c4450f27bf32a2a83292aba035b827a5623a14636ea583318c41")
    add_versions("1.75.0", "953db31e016db7bb207f11432bef7df100516eeb746843fa0486a222e3fd49cb")
    add_versions("1.74.0", "83bfc1507731a0906e387fc28b7ef5417d591429e51e788417fe9ff025e116b1")
    add_versions("1.73.0", "4eb3b8d442b426dc35346235c8733b5ae35ba431690e38c6a8263dce9fcbb402")
    add_versions("1.72.0", "59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722")
    add_versions("1.70.0", "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778")

    add_patches("1.75.0", path.join(os.scriptdir(), "patches", "1.75.0", "warning.patch"), "43ff97d338c78b5c3596877eed1adc39d59a000cf651d0bcc678cf6cd6d4ae2e")

    if is_plat("linux") then
        add_deps("bzip2", "zlib")
        add_syslinks("dl")
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
                      "iostreams",
                      "program_options",
                      "test"}

    add_configs("all",          { description = "Enable all library modules support.",  default = false, type = "boolean"})
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
        -- disable auto-link all libs
        package:add("defines", "BOOST_ALL_NO_LIB")
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
            import("core.tool.toolchain")
            local runenvs = toolchain.load("msvc"):runenvs()
            os.vrunv("bootstrap.bat", bootstrap_argv, {envs = runenvs})
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
            if package:config("pic") ~= false then
                table.insert(argv, "cxxflags=-fPIC")
            end
        end
        for _, libname in ipairs(libnames) do
            if package:config("all") or package:config(libname) then
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
            static void test() {
                std::string str("a,b");
                std::vector<std::string> vec;
                boost::algorithm::split(vec, str, boost::algorithm::is_any_of(","));
            }
        ]]}, {configs = {languages = "c++14"}}))

        if package:config("date_time") then
            assert(package:check_cxxsnippets({test = [[
                #include <boost/date_time/gregorian/gregorian.hpp>
                static void test() {
                    boost::gregorian::date d(2010, 1, 30);
                }
            ]]}, {configs = {languages = "c++14"}}))
        end
    end)
