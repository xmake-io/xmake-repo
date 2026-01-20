option("ver", {default = "0.21.4"})
option("thread_safe", {default = false})
option("libjpeg", {default = false})
option("lcms", {default = false})
option("jasper", {default = false})

if has_config("libjpeg") then
    add_requires("libjpeg")
end
if has_config("lcms") then
    add_requires("lcms")
end
if has_config("jasper") then
    add_requires("jasper")
end

add_rules("mode.debug", "mode.release")
set_languages("c++11")

if is_kind("shared") then
    add_defines("LIBRAW_BUILDLIB")
else
    add_defines("LIBRAW_NODLL")
end

if is_plat("windows") then
    add_defines("WIN32")
elseif is_plat("mingw") then
    add_defines(
        "M_PI=3.14159265358979323846",
        "M_SQRT1_2=0.70710678118654752440"
    )
end

if is_plat("windows", "mingw") then
    add_syslinks("ws2_32")
end

add_headerfiles("(libraw/*.h)")
add_includedirs(".")
set_version(get_config("ver"), {soname = true})

if has_config("libjpeg") then
    add_defines("USE_JPEG", "USE_JPEG8")
    add_packages("libjpeg")
end
if has_config("lcms") then
    add_defines("USE_LCMS2")
    add_packages("lcms")
end
if has_config("jasper") then
    add_defines("USE_JASPER")
    add_packages("jasper")
end

on_load(function (target)
    local version = import("core.base.semver").new(get_config("ver"))
    if version:ge("0.21") then
        target:add("files", "src/**.cpp")
        target:remove("files", "src/**_ph.cpp")
    else
        target:add("files",
            "src/libraw_cxx.cpp", "src/libraw_datastream.cpp", "src/libraw_c_api.cpp",
            "internal/dcraw_common.cpp", "internal/dcraw_fileio.cpp", "internal/demosaic_packs.cpp"
        )
    end
end)

target("raw")
    set_kind("$(kind)")

if has_config("thread_safe") then
    target("raw_r")
        set_kind("$(kind)")
        add_cxflags("-pthread")
        add_syslinks("pthread")
        add_deps("raw")
end
