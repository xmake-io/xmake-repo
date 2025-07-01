add_rules("mode.debug", "mode.release")
set_languages("c++14")

option("tools", {default = false})

target("LASlib")
    set_kind("$(kind)")
    add_files("LASlib/src/*.cpp|lasvlr.cpp|demzip_dll.cpp")
    add_files("LASzip/src/*.cpp|demzip_dll.cpp|laszip_dll.cpp")
    add_includedirs(
        "LASlib/inc",
        "LASzip/src",
        "LASzip/include/laszip", {public = true})

    set_encodings("source:utf-8")
    if is_plat("windows") then
        add_defines("NOMINMAX")
        add_defines("_CRT_SECURE_NO_WARNINGS", {public = true})
        if is_kind("shared") then
            add_defines("COMPILE_AS_DLL")
            add_defines("USE_AS_DLL", {interface = true})
        end
    end

    add_headerfiles(
        "LASzip/src/*.hpp",
        "LASzip/include/laszip/*.h",
        "LASlib/inc/*.hpp", {prefixdir = "LASlib"})

if has_config("tools") then
    target("tools_objects")
        set_kind("object")
        set_languages("c++17")
        add_files("src/geoprojectionconverter.cpp", "src/proj_loader.cpp")
        add_deps("LASlib")

    local tools = {
        "laszip",
        "lasinfo",
        "lasprecision",
        "txt2las",
        "las2las",
        "lasmerge",
        "lascopcindex",
        "las2txt",
        "lasdiff",
        "lasindex",
    }

    for _, tool in ipairs(tools) do
        target(tool)
            set_kind("binary")
            set_languages("c++17")
            add_files("src/" .. tool .. ".cpp")
            add_deps("tools_objects", "LASlib")
    end
end
