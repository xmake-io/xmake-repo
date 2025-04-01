option("version", {default = "2.6.0"})

add_rules("mode.debug", "mode.release")

if not is_plat("windows", "mingw", "msys") then
    add_defines("HAVE_STRNDUP")
end

local version = get_config("version")
if version then
    set_version(version, {soname = true})
    add_defines("PACKAGE_VERSION=\"" .. version .. "\"")
end

target("plist")
    set_kind("$(kind)")
    add_files("libcnary/*.c|cnary.c", "src/*.c")
    add_includedirs("src", "include", "libcnary/include", {public = true})
    add_headerfiles("include/(plist/*.h)")

    if is_kind("static") then
        add_defines("LIBPLIST_STATIC", {public = true})
    end

target("plist++")
    set_kind("$(kind)")
    add_files("src/*.cpp")
    add_deps("plist")
