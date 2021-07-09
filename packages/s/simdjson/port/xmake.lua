add_rules("mode.debug", "mode.release")

option("threads")
    set_default(true)
    set_showmenu(true)
    add_defines("SIMDJSON_THREADS_ENABLE")
    if not is_plat("windows") then 
        add_syslinks("pthread")
    end

option("noexceptions")
    set_default(false)
    set_showmenu(true)
    add_defines("SIMDJSON_EXCEPTIONS=0")

option("logging")
    set_default(false)
    set_showmenu(true)
    add_defines("SIMDJSON_VERBOSE_LOGGING")


target("simdjson")   
    set_languages("c++17")
    set_kind("$(kind)")
    if is_plat("windows") and is_kind("shared") then
        add_defines("SIMDJSON_BUILDING_WINDOWS_DYNAMIC_LIBRARY")
    end
    add_options("threads", "noexceptions", "logging")
    add_files("singleheader/simdjson.cpp")
    add_headerfiles("singleheader/simdjson.h")
