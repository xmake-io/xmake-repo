add_rules("mode.debug", "mode.release")

set_languages("c++11")

target("breakpad")
    set_kind("$(kind)")

    -- add_files("src/common/*.cc")
    -- add_headerfiles("src/(common/*.h)")
    -- add_files("src/client/*.cc")
    -- add_headerfiles("src/(client/*.h)")
    add_headerfiles("src/(google_breakpad/*.h)")

    if is_plat("windows") then
        add_files("src/common/windows/*.cc")
        add_files("src/client/windows/**.cc|tests/**.cc|unittests/**.cc")
        add_headerfiles("src/(client/windows/**.h)|tests/**.h|unittests/**.h")
    end

    remove_files("src/**_unittest.cc")

    add_includedirs("src")

    add_syslinks("dbghelp")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
