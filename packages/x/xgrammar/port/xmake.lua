option("XGRAMMAR_BUILD_PYTHON_BINDINGS", {default = false, description = "Build Python bindings"})

add_requires("dlpack 1.1")
add_rules("mode.debug", "mode.release")

-- config dependencies
if has_config("XGRAMMAR_BUILD_PYTHON_BINDINGS") then
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
    if has_config("XGRAMMAR_BUILD_PYTHON_BINDINGS") then
        add_files("cpp/nanobind/*.cc")
        add_packages("nanobind")
    end
target_end()
