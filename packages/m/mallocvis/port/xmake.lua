add_rules("mode.debug", "mode.release")

target("mallocvis")
    set_languages("c++17")
    set_kind("$(kind)")
    if is_plat("windows", "mingw") then
        add_syslinks("dbghelp")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end
    add_files("malloc_hook.cpp", "plot_actions.cpp")
    add_headerfiles("*.hpp|debug.hpp")
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
    add_defines("HAS_THREADS=1")
