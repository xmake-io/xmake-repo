package("dynareadout")
    set_homepage("https://github.com/PucklaJ/dynareadout")
    set_description("High-Performance C/C++ library for parsing binary output files and key files of LS Dyna (d3plot, binout, input deck)")
    set_license("zlib")

    add_urls("https://github.com/xmake-mirror/dynareadout/releases/download/$(version)/$(version).tar.gz")
    add_versions("24.07", "11138c1236f44434adf99ad86dc3315fcba17e59dd4b0ae0e6564972e2de12c5")

    add_configs("cpp_bind",    {description = "Build the C++ bindings",        default = true, type = "boolean"})
    add_configs("profiling",   {description = "Build with profiling features", default = true, type = "boolean"})
    if is_plat("mingw") then
        add_configs("python_bind", {description = "Build the python bindings", default = false, type = "boolean", readonly = true})
    else
        add_configs("python_bind", {description = "Build the python bindings", default = true, type = "boolean"})
    end

    on_check("windows", function (package)
        if package:config("python_bind") then
            if not package:is_arch("x64", "arm64") or package:is_cross() then
                raise("package(dynareadout) python bind is only supported windows x64/arm64 native build")
            end
        end
    end)

    on_load(function (package)
        wprint("The original repository PucklaJ/dynareadout is no longer public. You are using a mirror of this repository.")
        if package:config("cpp_bind") then
            package:add("links", "dynareadout_cpp", "dynareadout")
        else
            package:add("links", "dynareadout")
        end
        if package:config("python_bind") and not package:is_plat("mingw") then
            package:add("deps", "pybind11")
        end
        if package:is_plat("macosx") then
            package:add("deps", "boost", {configs = {filesystem = true}})
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        configs.build_cpp = package:config("cpp_bind")
        configs.profiling = package:config("profiling")
        configs.build_python = package:config("python_bind")

        os.cd("lib/dynareadout")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("binout_open", {includes = "binout.h", configs = {languages = "ansi"}}))
        assert(package:has_cfuncs("d3plot_open", {includes = "d3plot.h", configs = {languages = "ansi"}}))
        if package:config("cpp_bind") then
            assert(package:has_cxxtypes("dro::Binout", {includes = "binout.hpp", configs = {languages = "cxx17"}}))
            assert(package:has_cxxtypes("dro::D3plot", {includes = "d3plot.hpp", configs = {languages = "cxx17"}}))
            assert(package:has_cxxtypes("dro::Array<int32_t>",  {includes = {"array.hpp", "cstdint"}, configs = {languages = "cxx17"}}))
        end
        if package:config("profiling") then
            assert(package:check_csnippets({test = [[
                void test(int argc, char** argv) {
                    BEGIN_PROFILE_FUNC();
                    BEGIN_PROFILE_SECTION(mid_section);
                    END_PROFILE_SECTION(mid_section);
                    END_PROFILE_FUNC();
                    END_PROFILING("dynareadout_test_profiling.txt");
                }
            ]]}, {includes = "profiling.h", configs = {languages = "ansi"}}))
        end
        assert(package:has_cfuncs("sync_create", {includes = "sync.h", configs = {languages = "ansi"}}))
        assert(package:has_cfuncs("sync_lock",   {includes = "sync.h", configs = {languages = "ansi"}}))
    end)
