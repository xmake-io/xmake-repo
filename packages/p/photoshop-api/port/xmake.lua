add_rules("mode.debug", "mode.release")

set_languages("c++20")

add_requires("c-blosc2", {configs = {zlib = true, zstd = true}})
add_requires("simdutf", {configs = {iconv = false}})
add_requires("libdeflate")

target("photoshop-api")
    set_kind("$(kind)")
    add_files("PhotoshopAPI/src/**.cpp")
    add_includedirs("PhotoshopAPI/include", "PhotoshopAPI/src", "PhotoshopAPI/src/Util")
    add_headerfiles("PhotoshopAPI/include/*.h", "PhotoshopAPI/src/(**.h)")

    add_packages("c-blosc2", "simdutf", "libdeflate")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
