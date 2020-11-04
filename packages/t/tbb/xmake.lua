package("tbb")

    set_homepage("https://software.intel.com/en-us/tbb/")
    set_description("Threading Building Blocks (TBB) lets you easily write parallel C++ programs that take full advantage of multicore performance, that are portable, composable and have future-proof scalability.")

    if is_plat("windows") then
        -- use precompiled binary
        add_urls("https://github.com/oneapi-src/oneTBB/releases/download/v$(version)/tbb-$(version)-win.zip")
        add_versions("2020.3", "cda37eed5209746a79c88a658f8c1bf3782f58bd9f9f6ba0da3a16624a9bfaa1")
    else
        add_urls("https://github.com/oneapi-src/oneTBB/archive/v$(version).tar.gz")
        add_versions("2020.3", "ebc4f6aa47972daed1f7bf71d100ae5bf6931c2e3144cf299c8cc7d041dca2f3")

        if is_host("macosx") then
            add_configs("compiler", {description = "Compiler used to compile tbb." , default = "clang", type = "string", values = {"clang", "gcc", "icc", "cl", "icl", "[others]"}})
        else
            add_configs("compiler", {description = "Compiler used to compile tbb." , default = "gcc", type = "string", values = {"gcc", "clang", "icc", "cl", "icl", "[others]"}})
        end
    end

    on_install("macosx", "linux", "mingw@windows", "mingw@msys", function (package)
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
        os.cp("build/build_dir_" .. cfg .. "/**", package:installdir("lib"))
        package:add("links", "tbb", "tbbmalloc")
    end)

    on_install("windows", function (package)
        os.cp("tbb/include", package:installdir())
        if package:is_arch("x64", "x86_64") then
            os.cp("tbb/lib/intel64/vc14/**", package:installdir("lib"))
            os.cp("tbb/bin/intel64/vc14/**", package:installdir("bin"))
        else
            os.cp("tbb/lib/ia32/vc14/**", package:installdir("lib"))
            os.cp("tbb/bin/ia32/vc14/**", package:installdir("bin"))
        end
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
