set_xmakever("2.8.3")
set_languages("cxx11")

add_rules("mode.debug", "mode.release")

target("DebugUtils")
    set_kind("static")
    add_includedirs(
        "DebugUtils/Include",
        "Detour/Include",
        "DetourTileCache/Include",
        "Recast/Include")
    add_headerfiles("DebugUtils/Include/*.h")
    add_files("DebugUtils/Source/*.cpp")

target("Detour")
    set_kind("static")
    add_includedirs("Detour/Include")
    add_headerfiles("Detour/Include/*.h")
    add_files("Detour/Source/*.cpp")

target("DetourCrowd")
    set_kind("static")
    add_includedirs(
        "DetourCrowd/Include",
        "Detour/Include",
        "Recast/Include")
    add_headerfiles("DetourCrowd/Include/*.h")
    add_files("DetourCrowd/Source/*.cpp")

target("DetourTileCache")
    set_kind("static")
    add_includedirs(
        "DetourTileCache/Include",
        "Detour/Include",
        "Recast/Include")
    add_headerfiles("DetourTileCache/Include/*.h")
    add_files("DetourTileCache/Source/*.cpp")

target("Recast")
    set_kind("static")
    add_includedirs("Recast/Include")
    add_headerfiles("Recast/Include/*.h")
    add_files("Recast/Source/*.cpp")
