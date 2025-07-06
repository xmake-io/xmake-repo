-- Usage
--[[
    add_requires("nanobind")

    set_languages("c++17")

    target("my_ext")
        add_rules("python.library")
        add_files("src/*.cpp")
        add_packages("nanobind")

        on_run(function (target)
            import("private.action.run.runenvs")
            import("lib.detect.find_tool")

            local rundir = target:rundir()
            local addenvs, setenvs = runenvs.make(target)
            local args = {"-c", "\"import my_ext; print(my_ext.add(1, 2))\""}

            local python = find_tool("python3", {envs = addenvs})
            os.execv(python.program, args, {curdir = rundir, addenvs = addenvs, setenvs = setenvs})
        end)
--]]

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
