package("tbb")

    set_homepage("https://software.intel.com/en-us/tbb/")
    set_description("Threading Building Blocks (TBB) lets you easily write parallel C++ programs that take full advantage of multicore performance, that are portable, composable and have future-proof scalability.")

    if is_plat("windows") then
        -- use precompiled binary
        add_urls("https://github.com/oneapi-src/oneTBB/releases/download/v$(version)-win.zip", {version = function (version) return version .. (version:ge("2021.0") and "/oneapi-tbb-" or "/tbb-") .. version end})
        add_versions("2020.3", "cda37eed5209746a79c88a658f8c1bf3782f58bd9f9f6ba0da3a16624a9bfaa1")
        add_versions("2021.2.0", "9be37b1cb604a5905db0a15b2b893d85579fd0b2f1024859e1f75e96d7331a02")
        add_versions("2021.3.0", "90e2055cd4be55f79eedd3d50b2010bf05d1739309c4cdd219192d129e931093")
    else
        add_urls("https://github.com/oneapi-src/oneTBB/archive/v$(version).tar.gz")
        add_versions("2020.3", "ebc4f6aa47972daed1f7bf71d100ae5bf6931c2e3144cf299c8cc7d041dca2f3")
        add_versions("2021.2.0", "cee20b0a71d977416f3e3b4ec643ee4f38cedeb2a9ff015303431dd9d8d79854")
        add_versions("2021.3.0", "8f616561603695bbb83871875d2c6051ea28f8187dbe59299961369904d1d49e")

        add_patches("2021.2.0", path.join(os.scriptdir(), "patches", "2021.2.0", "gcc11.patch"), "181511cf4878460cb48ac0531d3ce8d1c57626d698e9001a0951c728fab176fb")

        if is_plat("macosx") then
            add_configs("compiler", {description = "Compiler used to compile tbb." , default = "clang", type = "string", values = {"clang", "gcc", "icc", "cl", "icl", "[others]"}})
        else
            add_configs("compiler", {description = "Compiler used to compile tbb." , default = "gcc", type = "string", values = {"gcc", "clang", "icc", "cl", "icl", "[others]"}})
        end
    end

    on_fetch("fetch")
    
    add_links("tbb", "tbbmalloc", "tbbmalloc_proxy")

    on_load("macosx", "linux", "mingw@windows", "mingw@msys", function (package)
        if package:version():ge("2021.0") then
            package:add("deps", "cmake")
        end
    end)

    on_install("macosx", "linux", "mingw@windows", "mingw@msys", function (package)
        if package:version():ge("2021.0") then
            if package:is_plat("mingw") then
                raise("mingw build is not supported in this version")
            end
            local configs = {"-DTBB_TEST=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            import("package.tools.cmake").install(package, configs)
        else
            local configs = {"-j4", "tbb_build_prefix=build_dir"}
            local cfg = package:debug() and "debug" or "release"
            table.insert(configs, "cfg=" .. cfg)
            table.insert(configs, "arch=" .. (package:is_arch("x86_64") and "intel64" or "ia32"))
            table.insert(configs, "compiler=" .. (package:config("compiler")))
            if package:is_plat("mingw") then
                os.vrunv("mingw32-make", configs)
            else
                os.vrunv("make", configs)
            end
            os.cp("include", package:installdir())
            os.rm("build/build_dir_" .. cfg .. "/*.d")
            os.rm("build/build_dir_" .. cfg .. "/*.o")
            os.cp("build/build_dir_" .. cfg .. "/**", package:installdir("lib"))
            if package:is_plat("mingw") then
                package:addenv("PATH", "lib")
            end
        end
    end)

    on_install("windows", function (package)
        local incdir = (package:version():ge("2021.0") and "include" or "tbb/include")
        local libdir = (package:version():ge("2021.0") and "lib/" or "tbb/lib/")
        local bindir = (package:version():ge("2021.0") and "redist/" or "tbb/bin/")
        os.cp(incdir, package:installdir())
        local prefix = ""
        if package:is_arch("x64", "x86_64") then
            prefix = "intel64/vc14"
        else
            prefix = "ia32/vc14"
        end
        if package:config("debug") then
            os.cp(libdir .. prefix .. "/*_debug.*", package:installdir("lib"))
            os.cp(bindir .. prefix .. "/*_debug.*", package:installdir("bin"))
        else
            os.cp(libdir .. prefix .. "/**|*_debug.*", package:installdir("lib"))
            os.cp(bindir .. prefix .. "/**|*_debug.*", package:installdir("bin"))
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using std::size_t;
                constexpr size_t N = 10;
                int X[N], Y[N], Z[N];
                for (int i = 0; i < N; ++i)
                    X[i] = i, Y[i] = 2*i;
                tbb::parallel_for(tbb::blocked_range<size_t>(0, N), [&](const tbb::blocked_range<size_t> &rg) {
                    for (size_t i = rg.begin(); i != rg.end(); ++i)
                        Z[i] = X[i] + Y[i];
                });
            }
        ]]}, {configs = {languages = "c++14"},
              includes = {"tbb/parallel_for.h", "tbb/blocked_range.h"}}))
    end)
