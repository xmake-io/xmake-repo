add_rules("mode.debug", "mode.release")

option("collect_static_var_data", {description = "Collect data also on static variable memory allocation", default = false, type = "boolean"})

if is_plat("linux", "macosx") then
    add_requires("libbacktrace")
end

target("memplumber")
    set_kind("$(kind)")
    set_languages("cxx11")

    add_files("memplumber.cpp")
    add_headerfiles("(memplumber.h)", "memplumber-internals.h")
    
    if is_plat("linux", "macosx") then
        add_packages("libbacktrace")
    elseif is_plat("windows", "mingw") then
        add_defines("_WIN32")
    end
    
    if has_config("collect_static_var_data") then
        add_defines("COLLECT_STATIC_VAR_DATA")
    end