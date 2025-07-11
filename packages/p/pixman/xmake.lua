package("pixman")
    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")
    set_license("MIT")

    add_urls("https://cairographics.org/releases/pixman-$(version).tar.gz", {alias = "home"})
    add_urls("https://www.x.org/archive/individual/lib/pixman-$(version).tar.gz", {alias = "home"})
    add_urls("https://gitlab.freedesktop.org/pixman/pixman/-/archive/pixman-$(version)/pixman-pixman-$(version).tar.gz", {alias = "gitlab"})
    add_urls("https://gitlab.freedesktop.org/pixman/pixman.git", {alias = "git"})

    add_versions("gitlab:0.42.0", "45c6462f6d6441923d4c17d06fa50ce066f0ceff0fc84af8d342df63c1079151")
    add_versions("gitlab:0.42.2", "4191a5084bae000a61e3513b06027b6f8f559d17d61769ed9de27dfb0cec8699")
    add_versions("gitlab:0.43.4", "2af0acd451e22ae9d86d3c8aa45fcc19e4cc33e86bec311e5328cc2171ff1720")
    add_versions("gitlab:0.46.2", "b40c00a15cf514bab2ea89301037def830d590a8e649950059c45a9c1b819bd0")

    add_versions("home:0.42.0", "07f74c8d95e4a43eb2b08578b37f40b7937e6c5b48597b3a0bb2c13a53f46c13")
    add_versions("home:0.42.2", "ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e")
    add_versions("home:0.43.2", "ea79297e5418fb528d0466e8b5b91d1be88857fa3706f49777b2925a72ae9924")
    add_versions("home:0.43.4", "a0624db90180c7ddb79fc7a9151093dc37c646d8c38d3f232f767cf64b85a226")
    add_versions("home:0.46.2", "3e0de5ba6e356916946a3d958192f15505dcab85134771bfeab4ce4e29bbd733")

    add_versions("git:0.46.2", "pixman-0.46.2")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")

    add_includedirs("include", "include/pixman-1")

    if on_check then
        on_check(function (package)
            if package:version():lt("0.43.0") and package:is_arch("arm.*") then
                assert(false, "package(pixman <0.43.0): Unsupported arm")
            end
        end)
    end

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "PIXMAN_API=__declspec(dllimport)")
        end

        local configs = {
            "-Dopenmp=disabled",
            "-Dlibpng=disabled",
            "-Dgtk=disabled",
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        if package:is_plat("android") then
            local ndk = package:toolchain("ndk"):config("ndk")
            if ndk then
                local cpu_features = path.join(ndk, "sources", "android", "cpufeatures")
                if os.isdir(cpu_features) then
                    table.insert(configs, "-Dcpu-features-path=" .. path.unix(cpu_features))
                end
            end
        elseif package:is_plat("windows") and package:is_arch("arm.*") then
            table.join2(configs, {"-Darm-simd=disabled", "-Dneon=disabled", "-Da64-neon=disabled", "-Dmmx=disabled"})
        end
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('demos')", "", {plain = true})
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
