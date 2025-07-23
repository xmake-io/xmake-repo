option("unicode", {default = true})

add_rules("mode.debug", "mode.release")

set_languages("c++11")

target("DuiLib")
    set_kind("$(kind)")
    add_files("DuiLib/**.cpp|DuiLib/StdAfx.cpp")
    add_includedirs("DuiLib")
    set_pcxxheader("DuiLib/StdAfx.h")

    if is_kind("shared") then
        add_defines("UILIB_EXPORTS")
    elseif is_kind("static") then
        add_defines("UILIB_STATIC", {public = true})
    end

    if has_config("unicode") then
        add_defines("UNICODE", "_UNICODE", {public = true})
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "comctl32", "imm32", "uuid", "winmm")
    end

    add_headerfiles("DuiLib/(**.h)")
    add_installfiles("DuiLib/Utils/Flash11.tlb", {prefixdir = "include/Utils"})
    add_installfiles("DuiLib/Utils/flash11.tlh", {prefixdir = "include/Utils"})
