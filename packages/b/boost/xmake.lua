package("boost")

    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/boost/archive/refs/tags/boost-$(version).tar.gz"

    add_versions("1.81.0", "5eb488cd517a5e0dc3dafdbc3e8151bcb49c851a1a8ec3b73c7d69733ca75e54")
    add_versions("1.80.0", "b1547a8b2aa159f15c0393323dd6d7e4d2eea7634c9a471442d989a406c0b51a")
    add_versions("1.79.0", "7d16551354059768397caa41f7ea3990650f80e4a045df1700bf623cd442e9d0")
    add_versions("1.78.0", "1157610e2d2412bb4ad193a35edcb85f337e18c2008bdef56680203f2a86d694")
    add_versions("1.77.0", "d00f100fee2479ea4ea93e163e08c1240cb781c421c4fb3a286f9c30356e2008")
    add_versions("1.76.0", "0ba70c1912a9a2626610e2c535de4e16b44a7e8e2390199ddcb5c745936f629e")
    add_versions("1.75.0", "fc46538e67ccf880ab1823c99f4d19cdbaa9d974dcbcda226c7e608d11903e14")
    add_versions("1.74.0", "0b9bc69b9d1d60fcad0478aa370ba80311a51ebba31538c23447c1032331ea5e")
    add_versions("1.73.0", "9f32cdebbdacd820ae0dd56c5b481c775b5196dac341bd23f67629dd3ef25d72")
    add_versions("1.72.0", "cd9a10e1e8c21d3ae329701fa8d0675c40e26ac9948dc3c2e6a781f100f9843e")
    add_versions("1.70.0", "a5a887563c72c77f206da1fcc24ff14c33d7a88017391c26132431cba7e55e40")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::boost")
    elseif is_plat("linux") then
        add_extsources("pacman::boost", "apt::libboost-all-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::boost")
    end

    add_patches("1.75.0", path.join(os.scriptdir(), "patches", "1.75.0", "warning.patch"), "43ff97d338c78b5c3596877eed1adc39d59a000cf651d0bcc678cf6cd6d4ae2e")

    if is_plat("linux") then
        add_deps("bzip2", "zlib")
        add_syslinks("pthread", "dl")
    end

    add_configs("pyver", {description = "python version x.y, etc. 3.10", default = "3.10"})
    local libnames = {"fiber",
                      "coroutine",
                      "context",
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
                      "test",
                      "chrono",
                      "contract",
                      "graph_parallel",
                      "json",
                      "log",
                      "thread",
                      "filesystem",
                      "math",
                      "mpi",
                      "nowide",
                      "python",
                      "stacktrace",
                      "type_erasure"}

    add_configs("all",          { description = "Enable all library modules support.",  default = false, type = "boolean"})
    add_configs("multi",        { description = "Enable multi-thread support.",  default = true, type = "boolean"})
    for _, libname in ipairs(libnames) do
        add_configs(libname,    { description = "Enable " .. libname .. " library.", default = (libname == "filesystem"), type = "boolean"})
    end

    on_load(function (package)
        function get_linkname(package, libname)
            local linkname
            if package:is_plat("windows") then
                linkname = (package:config("shared") and "boost_" or "libboost_") .. libname
            else
                linkname = "boost_" .. libname
            end
            if libname == "python" then
                linkname = linkname .. package:config("pyver"):gsub("%p+", "")
            end            
            if package:config("multi") then
                linkname = linkname .. "-mt"
            end
            if package:is_plat("windows") then
                local vs_runtime = package:config("vs_runtime")
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
            end
            return linkname
        end
        -- we need the fixed link order
        local sublibs = {log = {"log_setup", "log"}}
        for _, libname in ipairs(libnames) do
            local libs = sublibs[libname]
            if libs then
                for _, lib in ipairs(libs) do
                    package:add("links", get_linkname(package, lib))
                end
            else
                package:add("links", get_linkname(package, libname))
            end
        end
        -- disable auto-link all libs
        if package:is_plat("windows") then
            package:add("defines", "BOOST_ALL_NO_LIB")
        end

        if package:config("python") then
            if not package:config("shared") then
                package:add("defines", "BOOST_PYTHON_STATIC_LIB")
            end
            package:add("deps", "python " .. package:config("pyver") .. ".x", {configs = {headeronly = true}})
        end
    end)

    on_install("macosx", "linux", "windows", "bsd", "mingw", "cross", function (package)
        import("core.base.option")

        -- force boost to compile with the desired compiler
        local file = io.open("user-config.jam", "a")
        if file then
            if package:is_plat("macosx") then
                -- we uses ld/clang++ for link stdc++ for shared libraries
                -- and we need `xcrun -sdk macosx clang++` to make b2 to get `-isysroot` automatically
                local cc = package:build_getenv("ld")
                if cc and cc:find("clang", 1, true) and cc:find("Xcode", 1, true) then
                    cc = "xcrun -sdk macosx clang++"
                end
                file:print("using darwin : : %s ;", cc)
            elseif package:is_plat("windows") then
                file:print("using msvc : : \"%s\" ;", (package:build_getenv("cxx"):gsub("\\", "\\\\")))
            else
                file:print("using gcc : : %s ;", package:build_getenv("cxx"):gsub("\\", "/"))
            end
            file:close()
        end

        local bootstrap_argv =
        {
            "--prefix=" .. package:installdir(),
            "--libdir=" .. package:installdir("lib"),
            "--without-icu"
        }
        if package:is_plat("windows") then
            import("core.tool.toolchain")
            local runenvs = toolchain.load("msvc"):runenvs()
            -- for bootstrap.bat, all other arguments are useless
            bootstrap_argv = { "msvc" }
            os.vrunv("bootstrap.bat", bootstrap_argv, {envs = runenvs})
        elseif package:is_plat("mingw") and is_host("windows") then
            bootstrap_argv = { "gcc" }
            os.vrunv("bootstrap.bat", bootstrap_argv)
            -- todo looking for better solution to fix the confict between user-config.jam and project-config.jam
            io.replace("project-config.jam", "using[^\n]+", "")
        else
            os.vrunv("./bootstrap.sh", bootstrap_argv)
        end
        os.vrun("./b2 headers")

        local njobs = option.get("jobs") or tostring(os.default_njob())
        local argv =
        {
            "--prefix=" .. package:installdir(),
            "--libdir=" .. package:installdir("lib"),
            "-d2",
            "-j" .. njobs,
            "--hash",
            "--layout=tagged-1.66", -- prevent -x64 suffix in case cmake can't find it
            "--user-config=user-config.jam",
            "-sNO_LZMA=1",
            "-sNO_ZSTD=1",
            "install",
            "threading=" .. (package:config("multi") and "multi" or "single"),
            "debug-symbols=" .. (package:debug() and "on" or "off"),
            "link=" .. (package:config("shared") and "shared" or "static")
        }

        if package:config("lto") then
            table.insert(argv, "lto=on")
        end
        if package:is_arch("aarch64", "arm+.*") then
            table.insert(argv, "architecture=arm")
        end
        if package:is_arch(".+64.*") then
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
            table.insert(argv, "toolset=msvc")
        elseif package:is_plat("mingw") then
            table.insert(argv, "toolset=gcc")
        else
            table.insert(argv, "cxxflags=-std=c++14")
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
