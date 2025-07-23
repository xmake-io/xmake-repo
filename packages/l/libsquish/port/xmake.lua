option("sse2", {default = false})
option("openmp", {default = false})

if has_config("openmp") then
    add_requires("openmp")
    add_packages("openmp")
    add_defines("SQUISH_USE_OPENMP")
end

if has_config("sse2") then
    add_vectorexts("sse2")
    add_defines("SQUISH_USE_SSE=2")
end

add_rules("mode.debug", "mode.release")

set_languages("c++11")

target("squish")
    set_kind("$(kind)")
    add_files("*.cpp")
    add_headerfiles("squish.h")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
