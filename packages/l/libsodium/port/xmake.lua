add_rules("mode.debug", "mode.release")

if is_plat("windows") then
    add_defines("inline=__inline", "NATIVE_LITTLE_ENDIAN", "_CRT_SECURE_NO_WARNINGS")
end

target("sodium")
    set_kind("$(kind)")
    add_files("src/**.c")
    add_includedirs("src/libsodium/include/sodium", "builds/msvc")
    add_headerfiles("src/libsodium/include/(**.h)")
    add_headerfiles("builds/msvc/version.h", {prefixdir = "sodium"})

    if is_kind("static") then
        add_defines("SODIUM_STATIC")
    elseif is_kind("shared") and is_host("windows") then
        add_files("builds/msvc/resource.rc")
        add_defines("SODIUM_DLL_EXPORT")
    end
