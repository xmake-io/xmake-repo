add_rules("mode.debug", "mode.releasedbg", "mode.release")
add_requires("cpuinfo")

option("profiler", { default = false, description = "Enable ruy's built-in profiler (harms performance)" })

set_languages("cxx14")

target("ruy")
    set_kind("$(kind)")

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

    if is_arch("arm.*") then
        add_vectorexts("neon")
    end

    if not is_plat("windows") then 
        set_warnings("all", "extra")
    end

    if has_config("profiler") then
        add_defines("RUY_PROFILE")
    end