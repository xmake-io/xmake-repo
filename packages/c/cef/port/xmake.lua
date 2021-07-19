add_rules("mode.release", "mode.debug")
target("cef_dll_wrapper")
    set_kind("static")
    add_files("libcef_dll/**.cc|ctocpp/test/**.cc|cpptoc/test/**.cc")
    add_includedirs(".")
    add_headerfiles("include/(**.h)")
    add_defines("WRAPPING_CEF_SHARED")
    set_languages("c++14")
    if is_plat("windows") then
        -- fix std::max conflict with windows.h
        add_defines("NOMINMAX")
    end
