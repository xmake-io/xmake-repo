add_rules("mode.debug", "mode.release")
add_requires("boost", {configs = {filesystem = true}})
add_requires("libxml2", "minizip", "pcre", "uriparser")

option("common")
    set_default(true)
    if is_plat("windows") then
        add_defines("WIN32")
        if is_kind("shared") then
            add_defines("DOM_DYNAMIC", "DOM_EXPORT")
        end
    end
    set_languages("cxx11")
    add_defines("DOM_INCLUDE_LIBXML", "USE_URIPARSER")

target("collada-dom")
    set_kind("$(kind)")
    add_files("src/dae/*.cpp")
    add_files("src/modules/*/*.cpp")
    add_includedirs("include")
    add_headerfiles("include/(*.h)")
    add_headerfiles("include/(dae/*.h)")
    add_headerfiles("include/(modules/*.h)")
    add_options("common")
    add_packages("pcre", "boost", "libxml2", "minizip", "uriparser")

target("colladadom141")
    set_kind("static")
    add_deps("collada-dom")
    add_files("src/1.4/dom/*.cpp")
    add_includedirs("include")
    add_headerfiles("include/(1.4/dom/*.h)")
    add_options("common")
    add_packages("pcre", "boost")

target("colladadom150")
    set_kind("static")
    add_deps("collada-dom")
    add_files("src/1.5/dom/*.cpp")
    add_includedirs("include")
    add_headerfiles("include/(1.5/dom/*.h)")
    add_options("common")
    add_packages("pcre", "boost")
