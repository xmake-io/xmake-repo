package("dynareadout")

    set_homepage("https://github.com/PucklaJ/dynareadout")
    set_description("High-Performance C/C++ library for parsing binary output files and key files of LS Dyna (d3plot, binout, input deck)")

    add_urls("https://github.com/PucklaJ/dynareadout/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PucklaJ/dynareadout.git")
    add_versions("22.12", "2e430c718c610d4425e23d4c6c87fe4794bb8c76d3cc015988706dbf5027daa4")
    add_versions("23.01", "578080c734927cc925e7e91a52317bc3e710965071f1da50853b1e48f81a1c0f")
    add_versions("23.02", "054949a8774089fc217d7c0ec02996b53d331794c41941ed5006b90715bb4d30")
    add_versions("23.04", "929efad70c68931f35c76336ea8b23bf2da46022d5fd570f4efc06d776a94604")
    add_versions("23.05", "d33bb3acf6f62f7801c58755efbd49bfec2def37aee5397a17e2c38d8216bff6")
    add_versions("23.06", "515f0b0d20c46e00f393fb9bb0f2baf303244d39e35a080741276681eb454926")

    add_configs("cpp",         {description = "Build the C++ bindings",                       default = true,  type = "boolean"})
    add_configs("profiling",   {description = "Build with profiling features",                default = false, type = "boolean"})
    add_configs("thread_safe", {description = "Build with synchronisation for thread safety", default = true,  type = "boolean"})

    on_load(function (package)
        if package:config("cpp") then
            package:add("links", "dynareadout_cpp", "dynareadout")
        else
            package:add("links", "dynareadout")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        configs.build_test = "n"
        configs.build_cpp = package:config("cpp") and "y" or "n"
        configs.profiling = package:config("profiling") and "y" or "n"
        configs.thread_safe = package:config("thread_safe") and "y" or "n"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("binout_open", {includes = "binout.h", configs = {languages = "ansi"}}))
        assert(package:has_cfuncs("d3plot_open", {includes = "d3plot.h", configs = {languages = "ansi"}}))
        if package:config("cpp") then
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
        if package:config("thread_safe") then
            assert(package:has_cfuncs("sync_create", {includes = "sync.h", configs = {languages = "ansi"}}))
            assert(package:has_cfuncs("sync_lock",   {includes = "sync.h", configs = {languages = "ansi"}}))
        end
    end)
