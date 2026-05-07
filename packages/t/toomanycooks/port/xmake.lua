add_rules("mode.debug", "mode.release")

option("more_threads", {default = false, defines = "TMC_MORE_THREADS"})
option("priority_count", {default = "0"})
option("hwloc", {default = false, defines = "TMC_USE_HWLOC"})

if has_config("hwloc") then
    add_requires("hwloc")
end

target("toomanycooks")
    set_kind("$(kind)")

    add_includedirs("include", {public = true})
    add_headerfiles("include/(**.hpp)")
    add_files("lib.cpp")

    add_options("more_threads", "hwloc")

    if has_config("hwloc") then
        add_packages("hwloc")
    end

    if has_config("priority_count") and get_config("priority_count") ~= 0 then
        add_defines("TMC_PRIORITY_COUNT=" .. get_config("priority_count"))
    end
