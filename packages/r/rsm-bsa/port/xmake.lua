option("xmem", {showmenu = true, description = "build support for the xmem codec proxy", default = false})
option("ver", {showmenu = true, default = ""})

add_rules("mode.debug", "mode.release")

set_languages("c++20")

add_requires("rsm-mmio", "rsm-binary-io", "lz4", "zlib")

if is_plat("windows") then
    add_requires("directxtex")
end

if has_config("ver") then
    set_version(get_config("ver"))

    local vers = get_config("ver"):split("%.")
    major_ver = vers[1] or ""
    minor_ver = vers[2] or ""
    patch_ver = vers[3] or ""

    set_configvar("PROJECT_VERSION_MAJOR", major_ver)
    set_configvar("PROJECT_VERSION_MINOR", minor_ver)
    set_configvar("PROJECT_VERSION_PATCH", patch_ver)
    set_configvar("PROJECT_VERSION", get_config("ver"))
end

if has_config("xmem") then
    add_requires("reproc", "expected-lite", "xbyak", "taywee_args")

    add_requires("rsm-binary-io~32", {arch = "x86"})
    add_requires("rsm-mmio~32", {arch = "x86"})
    add_requires("expected-lite~32", {arch = "x86"})
    add_requires("xbyak~32", {arch = "x86"})
    add_requires("taywee_args~32", {arch = "x86"})

    target("rsm-bsa-common")
        set_kind("$(kind)")
        add_files("extras/xmem/src/bsa/**.cpp")
        add_includedirs("extras/xmem/src", {public = true})
        add_headerfiles("extras/xmem/src/(bsa/**.hpp)")

        add_packages("rsm-binary-io", "rsm-mmio", "expected-lite", "xbyak", {public = true})
        if is_plat("windows") and is_kind("shared") then
            add_rules("utils.symbols.export_all", {export_classes = true})
        end

    target("rsm-bsa-common-32")
        set_kind("static")
        add_files("extras/xmem/src/bsa/**.cpp")
        add_includedirs("extras/xmem/src", {public = true})
        add_packages("rsm-binary-io~32", "rsm-mmio~32", "expected-lite~32", "xbyak~32", {public = true})

    target("xmem")
        set_kind("binary")
        set_arch("x86")
        add_files("extras/xmem/src/main.cpp")
        add_files("extras/xmem/src/version.rc")
        add_includedirs("include")

        add_deps("rsm-bsa-common-32")
        add_packages("taywee_args~32")

        set_configdir("extras/xmem/src")
        add_configfiles("extras/xmem/cmake/version.rc.in", {pattern = "@(.-)@"})
        set_configvar("PROJECT_NAME", "bsa")
end

target("rsm-bsa")
    set_kind("$(kind)")
    add_files("src/**.cpp")
    add_includedirs("include", "src")
    add_headerfiles("include/(bsa/**.hpp)")
    add_installfiles("visualizers/*.natvis", {prefixdir = "include/natvis"})

    set_configdir("include/bsa")
    add_configfiles("cmake/project_version.hpp.in", {pattern = "@(.-)@"})

    add_packages("rsm-mmio", "rsm-binary-io", "lz4", "zlib")

    if is_plat("windows") then
        add_packages("directxtex")
        add_syslinks("ole32")
        if is_kind("shared") then
            add_rules("utils.symbols.export_all", {export_classes = true})
        end
    end

    if has_config("xmem") then
        add_deps("rsm-bsa-common")
        add_defines("BSA_SUPPORT_XMEM=1")
        add_packages("reproc")
    end
