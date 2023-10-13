add_rules("mode.debug", "mode.release")

set_languages("c++11")

target("breakpad")
    set_kind("$(kind)")
    add_files("src/processor/basic_code_modules.cc",
              "src/processor/dump_context.cc",
              "src/processor/dump_object.cc",
              "src/processor/logging.cc",
              "src/processor/minidump.cc",
              "src/processor/pathname_stripper.cc")
    add_headerfiles("src/(processor/basic_code_modules.h)",
                    "src/(processor/logging.h)",
                    "src/(processor/pathname_stripper.h)")

    -- add_files("src/common/*.cc")
    add_headerfiles("src/(common/*.h)")
    add_headerfiles("src/(google_breakpad/**.h)")

    add_includedirs("src")
    remove_files("src/**_unittest.cc")

    if is_plat("windows") then
        add_defines("UNICODE", "_UNICODE")

        add_files("src/common/windows/guid_string.cc",
                  "src/common/windows/string_utils.cc",
                  "src/common/windows/string_conversion.cc")
        add_headerfiles("src/(common/windows/guid_string.h)",
                        "src/(common/windows/string_utils-inl.h)",
                        "src/(common/windows/string_conversion.h)")

        add_headerfiles("src/(client/windows/common/*.h)")
        for _, dir in ipairs({"crash_generation", "handler", "sender"}) do
            add_files(path.join("src/client/windows", dir, "*.cc"))
            add_headerfiles(path.join("src/(client/windows", dir, "*.h)"))
        end

        add_syslinks("dbghelp")
        if is_kind("shared") then
            add_rules("utils.symbols.export_all", {export_classes = true})
        end
    end
