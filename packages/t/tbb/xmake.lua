package("tbb")

    set_homepage("https://software.intel.com/en-us/tbb/")
    set_description("Threading Building Blocks (TBB) lets you easily write parallel C++ programs that take full advantage of multicore performance, that are portable, composable and have future-proof scalability.")

    if is_plat("windows") then
        add_urls("https://github.com/oneapi-src/oneTBB/$(version)", {version = function (version)
            if version:ge("2021.0") then
                return "archive/v" .. version .. ".tar.gz"
            else
                return "releases/download/v" .. version .. "/tbb-" .. version .. "-win.zip"
            end
        end})
        add_versions("2020.3", "cda37eed5209746a79c88a658f8c1bf3782f58bd9f9f6ba0da3a16624a9bfaa1")
        add_versions("2021.2.0", "cee20b0a71d977416f3e3b4ec643ee4f38cedeb2a9ff015303431dd9d8d79854")
        add_versions("2021.3.0", "8f616561603695bbb83871875d2c6051ea28f8187dbe59299961369904d1d49e")
        add_versions("2021.4.0", "021796c7845e155e616f5ecda16daa606ebb4c6f90b996e5c08aebab7a8d3de3")
        add_versions("2021.5.0", "e5b57537c741400cf6134b428fc1689a649d7d38d9bb9c1b6d64f092ea28178a")
        add_versions("2021.7.0", "2cae2a80cda7d45dc7c072e4295c675fff5ad8316691f26f40539f7e7e54c0cc")
    else
        add_urls("https://github.com/oneapi-src/oneTBB/archive/v$(version).tar.gz")
        add_versions("2020.3", "ebc4f6aa47972daed1f7bf71d100ae5bf6931c2e3144cf299c8cc7d041dca2f3")
        add_versions("2021.2.0", "cee20b0a71d977416f3e3b4ec643ee4f38cedeb2a9ff015303431dd9d8d79854")
        add_versions("2021.3.0", "8f616561603695bbb83871875d2c6051ea28f8187dbe59299961369904d1d49e")
        add_versions("2021.4.0", "021796c7845e155e616f5ecda16daa606ebb4c6f90b996e5c08aebab7a8d3de3")
        add_versions("2021.5.0", "e5b57537c741400cf6134b428fc1689a649d7d38d9bb9c1b6d64f092ea28178a")
        add_versions("2021.7.0", "2cae2a80cda7d45dc7c072e4295c675fff5ad8316691f26f40539f7e7e54c0cc")

        add_patches("2021.2.0", path.join(os.scriptdir(), "patches", "2021.2.0", "gcc11.patch"), "181511cf4878460cb48ac0531d3ce8d1c57626d698e9001a0951c728fab176fb")
        add_patches("2021.5.0", path.join(os.scriptdir(), "patches", "2021.5.0", "i386.patch"), "1a1c11724839cf98b1b8f4d415c0283ec7719c330b11503c578739eb02889ec0")

        if is_plat("macosx") then
            add_configs("compiler", {description = "Compiler used to compile tbb." , default = "clang", type = "string", values = {"clang", "gcc", "icc", "cl", "icl", "[others]"}})
        else
            add_configs("compiler", {description = "Compiler used to compile tbb." , default = "gcc", type = "string", values = {"gcc", "clang", "icc", "cl", "icl", "[others]"}})
        end
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_fetch("fetch")

    add_links("tbb", "tbbmalloc", "tbbmalloc_proxy")

    on_load(function (package)
        if package:version():ge("2021.0") then
            package:add("deps", "cmake")
        end
    end)

    on_install("macosx", "linux", "mingw@windows", "mingw@msys", "android", function (package)
        if package:version():ge("2021.0") then
            if package:version():le("2021.4") and package:is_plat("mingw") then
                raise("mingw build is not supported in this version")
            end
            local configs = {"-DTBB_TEST=OFF", "-DTBB_STRICT=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            if package:is_plat("mingw") then
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_arch("x86_64") and "AMD64" or "i686"))
            end
            import("package.tools.cmake").install(package, configs)
            if package:is_plat("mingw") then
                local ext = package:config("shared") and ".dll.a" or ".a"
                local libfiles = os.files(path.join(package:installdir("lib"), "libtbb*" .. ext))
                for _, libfile in ipairs(libfiles) do
                    if libfile:match(".+libtbb%d+" .. ext) then
                        os.cp(libfile, path.join(package:installdir("lib"), "libtbb" .. ext))
                        break
                    end
                end
            end
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
        if package:version():ge("2021.0") then
            local configs = {"-DTBB_TEST=OFF", "-DTBB_STRICT=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            import("package.tools.cmake").install(package, configs)
        else
            local incdir = "tbb/include"
            local libdir = "tbb/lib/"
            local bindir = "tbb/bin/"
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
