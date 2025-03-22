-- https://github.com/wjakob/nanobind/blob/master/cmake/nanobind-config.cmake
-- https://github.com/mesonbuild/wrapdb/blob/master/subprojects/packagefiles/nanobind/meson.build

add_rules("mode.debug", "mode.release")

add_requires("robin-map", "python >=3.8")

set_languages("c++17")

target("nanobind")
    set_kind("$(kind)")
    add_files("src/*.cpp|nb_combined.cpp")
    add_includedirs("include", {public = true})

    add_packages("robin-map", "python")

    if is_mode("release") then
        add_defines("NB_COMPACT_ASSERTIONS")
    end

    if is_kind("shared") then
        add_defines("NB_BUILD")
        add_defines("NB_SHARED", {public = true})

        if is_plat("macosx") then
            add_shflags("-Wl,-dead_strip", "-Wl,x", "-Wl,-S", "-Wl,@cmake/darwin-ld-cpython.sym", {public = true})
        elseif not is_plat("windows") then
            add_shflags("-Wl,-s", {public = true})
        end
    end

    add_headerfiles("include/(nanobind/**.h)")
    add_installfiles("(cmake/*)")
    add_installfiles("*.py", {prefixdir = "python"})
