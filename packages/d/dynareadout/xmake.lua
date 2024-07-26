package("dynareadout")

    set_homepage("https://github.com/PucklaJ/dynareadout")
    set_description("High-Performance C/C++ library for parsing binary output files and key files of LS Dyna (d3plot, binout, input deck)")

    add_urls("https://github.com/PucklaJ/dynareadout/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PucklaJ/dynareadout.git")
    add_versions("24.07", "9b43e0e16d86b04f02d3bb45d7b999cb559ef229b85455a403b89415e761e7bb")
    add_versions("24.05", "86e045f23d1e1d3ed2e002774f8f04badc5c974c3441bdc07f3a82c5711328c9")
    add_versions("24.03", "d91feb2ebfa604b543dd6d98c3dd5aee5c489e6987159fef78dfcea1aad64bd5")
    add_versions("22.12", "2e430c718c610d4425e23d4c6c87fe4794bb8c76d3cc015988706dbf5027daa4")
    add_versions("23.01",   "578080c734927cc925e7e91a52317bc3e710965071f1da50853b1e48f81a1c0f")
    add_versions("23.02",   "054949a8774089fc217d7c0ec02996b53d331794c41941ed5006b90715bb4d30")
    add_versions("23.04",   "929efad70c68931f35c76336ea8b23bf2da46022d5fd570f4efc06d776a94604")
    add_versions("23.05",   "d33bb3acf6f62f7801c58755efbd49bfec2def37aee5397a17e2c38d8216bff6")
    add_versions("23.06",   "515f0b0d20c46e00f393fb9bb0f2baf303244d39e35a080741276681eb454926")
    add_versions("23.07",   "6db52a13771cdb7613b97cf0d2bcffdb87ce0cce4cba7e6d80330977b2ac6210")
    add_versions("23.08",   "5be972426f67ce63a7ac3beaf3866b824abbc9c15af2d47d1fea21687417b493")
    add_versions("23.09",   "a62e0575521aacf3f567dfd578d6edc51edc07d4b744e5b5ae5d30f662be424b")
    add_versions("23.10",   "834d356e80019a7288001c2796c9ce14c2a8e5494c1051fae402f4503b10c1e5")
    add_versions("23.10.1", "6ebb6e9d9b3db637476cc9bd5342e4779be175f87225261da35c9270790e77d7")
    add_versions("23.11",   "2222bea87af9289dbc1a52adc5f09058863c503003e94193ca9388eff9e4ff04")
    add_versions("23.12",   "6afc9c0857b6227e39466aae00db606d3376e61d518bb73544d8240fe3a66a90")
    add_versions("24.01",   "f39094567272816c9a7dd84d3eaa0ef5c26309eeeadba814cac12f82e93ae0e1")
    add_versions("24.02",   "acd483bd737a7769087befa1eb2010426c1328bb84ab0481ea11cdeb7655c64e")

    add_configs("cpp",         {description = "Build the C++ bindings",                       default = true,  type = "boolean"})
    add_configs("profiling",   {description = "Build with profiling features",                default = false, type = "boolean"})
    add_configs("thread_safe", {description = "Build with synchronisation for thread safety", default = true,  type = "boolean"})

    on_load(function (package)
        if package:config("cpp") then
            package:add("links", "dynareadout_cpp", "dynareadout")
        else
            package:add("links", "dynareadout")
        end
        if package:is_plat("macosx") then
            package:add("deps", "boost")
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
