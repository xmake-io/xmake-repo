add_requires("cpptrace <=0.4.0")

if has_config("decompose") then
    add_defines("ASSERT_DECOMPOSE_BINARY_LOGICAL")
end

if has_config("lowercase") then
    add_defines("ASSERT_LOWERCASE")
end

if has_config("magic_enum") then
    add_requires("magic_enum")
    add_packages("magic_enum")
    add_defines("ASSERT_USE_MAGIC_ENUM")
end

add_rules("mode.debug", "mode.release")
set_languages("c++17")

target("assert")
    set_kind("$(kind)")
    add_files("src/*.cpp")
    add_includedirs("include")
    add_headerfiles("include/*.hpp")
    add_packages("cpptrace")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
