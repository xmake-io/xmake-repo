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

-- The package recipe selects a version-compatible Python dependency, and
-- package.tools.xmake forwards that resolved version into this port.
add_requires("robin-map", "python")

set_languages("c++17")

target("nanobind")
    set_kind("$(kind)")
    -- nb_backend.cpp is a standalone split-mode backend module and requires
    -- NB_BACKEND_NAME; it is not part of the regular nanobind core library.
    add_files("src/*.cpp|nb_combined.cpp|nb_backend.cpp")
    add_includedirs("include", {public = true})

    add_packages("robin-map", "python")
    add_defines("NB_BUILD")

    if is_mode("release") then
        add_defines("NB_COMPACT_ASSERTIONS")
    end

    if is_kind("shared") then
        add_defines("NB_SHARED", {public = true})

        if is_plat("macosx") then
            add_shflags("-Wl,-dead_strip", "-Wl,x", "-Wl,-S", "-Wl,@cmake/darwin-ld-cpython.sym", {public = true})
        elseif not is_plat("windows") then
            add_shflags("-Wl,-s", {public = true})
        end
    end

    if not is_plat("windows") then
        add_cxflags("-fno-strict-aliasing")
    end

    add_headerfiles("include/(nanobind/**.h)")
    add_installfiles("(cmake/*)")
    add_installfiles("*.py", {prefixdir = "python"})
