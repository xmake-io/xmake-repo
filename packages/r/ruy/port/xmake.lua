add_rules("mode.debug", "mode.releasedbg", "mode.release")
add_requires("cpuinfo")

option("profiler", { default = false, description = "Enable ruy's built-in profiler (harms performance)" })

set_languages("cxx14")

target("ruy")
    set_kind("static")

    add_files("ruy/**.cc")
    remove_files("ruy/test*.cc", "ruy/*test.cc")
    remove_files("ruy/profiler/test*.cc")
    remove_files("ruy/benchmark.cc")

    remove_files("ruy/profiler/test*.cc")
    remove_files("ruy/profiler/test.cc")

    add_headerfiles("(ruy/**.h)")
    remove_headerfiles("ruy/gtest_wrapper.h")
    remove_headerfiles("ruy/profiler/test*.h")

    add_includedirs(".")
    set_optimize("fastest")

    add_packages("cpuinfo")

    on_load(function (target) 
        if is_arch("arm.*") then
            target:add("cxflags", "-mfpu=neon")
        end

        if not is_plat("windows") then 
            target:add("cxflags", "-Wall", "-Wextra", "-Wc++14-compat", "-Wundef")
        end

        if has_config("profiler") then
            target:add("defines", "RUY_PROFILE")
        end
    end)