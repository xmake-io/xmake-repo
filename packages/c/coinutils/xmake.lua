package("coinutils")
    set_homepage("https://github.com/coin-or/CoinUtils")
    set_description("COIN-OR Utilities")
    set_license("EPL-2.0")

    add_urls("https://github.com/coin-or/CoinUtils/archive/refs/tags/releases/$(version).tar.gz",
             "https://github.com/coin-or/CoinUtils.git")

    add_versions("2.11.12", "eef1785d78639b228ae2de26b334129fe6a7d399c4ac6f8fc5bb9054ba00de64")

    if not is_subhost("windows") then
        add_deps("autotools")
    end
    add_deps("bzip2", "zlib")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("Accelerate")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function(package)
        if is_subhost("windows") then
            local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
            if package:is_arch64() then
                package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true, mingw64_toolchain = true, make = true}})
            else
                package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true, mingw32_toolchain = true, make = true}})
            end
        end
    end)

    on_install("!cross and !wasm", function (package)
        local configs = {"--without-blas", "--without-lapack"}
        if package:is_plat("windows") then
            local wrapper_path = path.join(os.tmpdir(), "msvc_ar_wrapper.bat")
            io.writefile(wrapper_path, [[
@echo off
setlocal enabledelayedexpansion
:: Capture output file name
set output_file=%~1
:: Remove first argument (output file)
shift
:: Process remaining arguments (object files)
set objects=
:loop
if "%~1"=="" goto end
set objects=!objects! "%~1"
shift
goto loop
:end
:: Create output directory if needed
for %%i in ("%output_file%") do set outdir=%%~dpi
if not exist "%outdir%" mkdir "%outdir%"
:: Build library
lib -nologo -OUT:"%output_file%" %objects%
endlocal
]])
            table.insert(configs, [[CC=cl -nologo]])
            table.insert(configs, [[CXX=cl -nologo]])
            table.insert(configs, [[LD=link -nologo]])
            table.insert(configs, [[NM=dumpbin -symbols]])
            table.insert(configs, [[AR=]] .. path.cygwin(wrapper_path))
            table.insert(configs, [[OBJDUMP=:]])
            table.insert(configs, [[RANLIB=:]])
            table.insert(configs, [[STRIP=:]])
            table.insert(configs, [[CXXFLAGS=-EHsc -FS]]) -- /std:c++17 /Zc:__cplusplus
        end
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <coin/CoinPackedVector.hpp>
            void test() {
                const int ne = 4;
                const int inx[ne] =   {  1,   4,  0,   2 };
                const double el[ne] = { 10., 40., 1., 50. };
                CoinPackedVector r(ne, inx, el);
                r.sortIncrElement();
                r.sortOriginalOrder();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
