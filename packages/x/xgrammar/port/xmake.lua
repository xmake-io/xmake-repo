option("python_bindings", {default = false, description = "Build Python bindings"})

add_requires("dlpack 1.1")
add_rules("mode.debug", "mode.release")

-- config dependencies
if has_config("python_bindings") then
    add_requires("nanobind v2.5.0")
end

-- common global settings
add_packages("dlpack")
set_languages("c++17")
add_includedirs("3rdparty/picojson")
add_includedirs("include", {public = true})
add_headerfiles("include/(**.h)")

-- xgrammar static library
target("xgrammar")
    set_kind("$(kind)")
    add_files("cpp/*.cc")
    add_files("cpp/support/*.cc")
    if has_config("python_bindings") then
        add_files("cpp/nanobind/*.cc")
        add_packages("nanobind")
    end
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
