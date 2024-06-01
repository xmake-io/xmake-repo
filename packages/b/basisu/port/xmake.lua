option("opencl", {default = false})
option("tools", {default = false})

add_rules("mode.debug", "mode.release")

set_languages("c++11")
add_rules("utils.install.cmake_importfiles")

if has_config("opencl") then
    add_requires("opencl")
    add_packages("opencl")
    add_defines("BASISU_SUPPORT_OPENCL")
end

add_requires("zstd")
add_packages("zstd")
add_defines("BASISD_SUPPORT_KTX2_ZSTD")

target("basisu")
    set_kind("$(kind)")
    add_files("encoder/*.cpp", "transcoder/*.cpp")
    add_headerfiles("(encoder/*.h)", "(transcoder/*.h)", "(transcoder/*.inc)", {prefixdir = "basisu"})

    add_vectorexts("all")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

if has_config("tools") then
    target("basisu_tool")
        set_kind("binary")
        add_files("basisu_tool.cpp")
        add_deps("basisu")
end
