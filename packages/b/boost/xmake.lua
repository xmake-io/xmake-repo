package("boost")

    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    add_urls("https://boostorg.jfrog.io/artifactory/main/release/$(version).tar.bz2", {version = function (version)
            return version .. "/source/boost_" .. (version:gsub("%.", "_"))
        end})
    add_urls("https://github.com/xmake-mirror/boost/releases/download/boost-$(version).tar.bz2", {version = function (version)
            return version .. "/boost_" .. (version:gsub("%.", "_"))
        end})
    add_versions("1.83.0", "6478edfe2f3305127cffe8caf73ea0176c53769f4bf1585be237eb30798c3b8e")
    add_versions("1.82.0", "a6e1ab9b0860e6a2881dd7b21fe9f737a095e5f33a3a874afc6a345228597ee6")
    add_versions("1.81.0", "71feeed900fbccca04a3b4f2f84a7c217186f28a940ed8b7ed4725986baf99fa")
    add_versions("1.80.0", "1e19565d82e43bc59209a168f5ac899d3ba471d55c7610c677d4ccf2c9c500c0")
    add_versions("1.79.0", "475d589d51a7f8b3ba2ba4eda022b170e562ca3b760ee922c146b6c65856ef39")
    add_versions("1.78.0", "8681f175d4bdb26c52222665793eef08490d7758529330f98d3b29dd0735bccc")
    add_versions("1.77.0", "fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854")
    add_versions("1.76.0", "f0397ba6e982c4450f27bf32a2a83292aba035b827a5623a14636ea583318c41")
    add_versions("1.75.0", "953db31e016db7bb207f11432bef7df100516eeb746843fa0486a222e3fd49cb")
    add_versions("1.74.0", "83bfc1507731a0906e387fc28b7ef5417d591429e51e788417fe9ff025e116b1")
    add_versions("1.73.0", "4eb3b8d442b426dc35346235c8733b5ae35ba431690e38c6a8263dce9fcbb402")
    add_versions("1.72.0", "59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722")
    add_versions("1.70.0", "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778")

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
            if libname == "python" or libname == "numpy" then
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
            else
                if package:debug() then
                    linkname = linkname .. "-d"
                end
            end
            return linkname
        end
        -- we need the fixed link order
        local sublibs = {log = {"log_setup", "log"},
                         python = {"python", "numpy"},
                         stacktrace = {"stacktrace_backtrace", "stacktrace_basic"}}
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

        -- get toolchain
        local toolchain
        if package:is_plat("windows") then
            toolchain = package:toolchain("clang-cl") or package:toolchain("msvc") or
                import("core.tool.toolchain").load("msvc", {plat = package:plat(), arch = package:arch()})
        end

        -- force boost to compile with the desired compiler
        local win_toolset
        local file = io.open("user-config.jam", "a")
        if file then
            local cxx = package:build_getenv("cxx")
            if package:is_plat("macosx") then
                -- we uses ld/clang++ for link stdc++ for shared libraries
                -- and we need `xcrun -sdk macosx clang++` to make b2 to get `-isysroot` automatically
                local cc = package:build_getenv("ld")
                if cc and cc:find("clang", 1, true) and cc:find("Xcode", 1, true) then
                    cc = "xcrun -sdk macosx clang++"
                end
                file:print("using darwin : : %s ;", cc)
            elseif package:is_plat("windows") then
                local vs_toolset = toolchain:config("vs_toolset")
                local msvc_ver = ""
                win_toolset = "msvc"
                if toolchain:name() == "clang-cl" then
                    win_toolset = "clang-win"
                    cxx = cxx:gsub("(clang%-cl)$", "%1.exe", 1)
                    msvc_ver = ""
                elseif vs_toolset then
                    local i = vs_toolset:find("%.")
                    msvc_ver = i and vs_toolset:sub(1, i + 1)
                end

                -- Specifying a version will disable b2 from forcing tools
                -- from the latest installed msvc version.
                file:print("using %s : %s : \"%s\" ;", win_toolset, msvc_ver, cxx:gsub("\\", "\\\\"))
            else
                cxx = cxx:gsub("gcc$", "g++")
                cxx = cxx:gsub("clang$", "clang++")
                file:print("using gcc : : %s ;", cxx:gsub("\\", "/"))
            end
            file:close()
        end

        local bootstrap_argv =
        {
            "--prefix=" .. package:installdir(),
            "--libdir=" .. package:installdir("lib"),
            "--without-icu"
        }

        local runenvs
        if package:is_plat("windows") then
            runenvs = toolchain:runenvs()
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
            "-q", -- quit on first error
            "--layout=tagged-1.66", -- prevent -x64 suffix in case cmake can't find it
            "--user-config=user-config.jam",
            "-sNO_LZMA=1",
            "-sNO_ZSTD=1",
            "install",
            "threading=" .. (package:config("multi") and "multi" or "single"),
            "debug-symbols=" .. (package:debug() and "on" or "off"),
            "link=" .. (package:config("shared") and "shared" or "static"),
            "variant=" .. (package:is_debug() and "debug" or "release"),
            "runtime-debugging=" .. (package:is_debug() and "on" or "off")
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
            table.insert(argv, "toolset=" .. win_toolset)
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

        if package:is_plat("linux") then
            table.insert(argv, "pch=off")
        end

        os.vrunv("./b2", argv, {envs = runenvs})
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
