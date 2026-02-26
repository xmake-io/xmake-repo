option("ver", {default = "v2.5.1"})
option("libdeflate", {default = true})

add_rules("mode.debug", "mode.release")

if has_config("libdeflate") then
    add_requires("libdeflate")
    add_packages("libdeflate")
else
    add_requires("zlib")
    add_packages("zlib")
end

target("ptex")
    set_kind("$(kind)")
    add_files("src/ptex/*.cpp")
    add_includedirs("src/ptex", {public = true})
    add_headerfiles("src/ptex/(*.h)")
    set_configdir("src/ptex")
    add_configfiles("src/ptex/PtexVersion.h.in", {pattern = "@(.-)@"})
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end
    if is_kind("static") then
        add_defines("PTEX_STATIC", {public = true})
    else
        add_defines("PTEX_EXPORTS")
    end

    on_load(function (target)
        import("core.base.semver")

        local version = semver.new(get_config("ver"))
        target:set("configvar", "PTEX_MAJOR_VERSION", version:major())
        target:set("configvar", "PTEX_MINOR_VERSION", version:minor())

        if version:ge("2.5.0") then
            target:set("languages", "c++17", {public = true})
        end
    end)

target("ptxinfo")
    set_kind("binary")
    add_deps("ptex")
    add_files("src/utils/ptxinfo.cpp")
