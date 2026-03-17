package("libp2p")
    set_homepage("https://github.com/sekrit-twc/libp2p")
    set_description("Pack/unpack pixels.")
    set_license("WTFPL")

    add_urls("https://github.com/sekrit-twc/libp2p.git", {submodules = false})
    add_versions("2025.06.07", "8a1a062ad203cd5469bf7a0f78de0061add0beb7")

    if is_arch("x64", "x86", "x86_64", "i386") then
        add_configs("simd", {description = "Enable SIMD", default = true, type = "boolean"})
    end
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        if package:config("simd") then
            package:add("defines", "P2P_SIMD")
        end

        io.writefile("xmake.lua", [[
            option("simd", {default = false})
            add_rules("mode.release", "mode.debug")
            set_languages("c++14")
            target("libp2p")
                set_kind("$(kind)")
                add_files("*.cpp", "simd/*.cpp")
                add_headerfiles("*.h", {prefixdir = "libp2p"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                if has_config("simd") then
                    add_defines("P2P_SIMD")
                    add_vectorexts("sse4.2")
                end
        ]])
        import("package.tools.xmake").install(package, {simd = package:config("simd")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("p2p_select_unpack_func", {includes = "libp2p/p2p_api.h"}))
    end)
