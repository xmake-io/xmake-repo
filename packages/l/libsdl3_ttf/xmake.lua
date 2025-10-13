package("libsdl3_ttf")
    set_homepage("https://github.com/libsdl-org/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::sdl3-ttf")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl3_ttf", "apt::libsdl3-ttf-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl3_ttf")
    end

    add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL3_ttf-$(version).zip",
             "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL3_ttf-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_ttf.git", {alias = "github", submodules = false})

    add_versions("archive:3.2.2", "d38c2078630e015777aafa1a1ce627df4323114a920c313274346c372ba0d19d")
    add_versions("archive:3.2.0", "ea75fa02ab328cccdff8bf36d2ec891e445e94fa301cd0ef34c662e24d30b704")

    add_versions("github:3.2.2", "release-3.2.2")
    add_versions("github:3.2.0", "release-3.2.0")

    add_deps("cmake", "freetype")

    add_configs("harfbuzz", {description = "Use harfbuzz to improve text shaping", default = false, type = "boolean"})
    add_configs("plutosvg", {description = "Use plutosvg for color emoji support", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    if on_check then
        on_check("android", function (package)
            if package:config("harfbuzz") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(libsdl3_ttf) dep(harfbuzz) require ndk version > 22")
            end
        end)
    end

    on_load(function (package)
        -- libsdl3_ttf 3.2.0 requires libsdl3 >= 3.2.6
        package:add("deps", "libsdl3 >=3.2.6", { configs = { shared = package:config("shared") }})
        if package:config("harfbuzz") then
            package:add("deps", "harfbuzz")
        end
        if package:config("plutosvg") then
            package:add("deps", "plutosvg", "plutovg")
        end
    end)

    on_install(function (package)
        local configs = {"-DSDLTTF_SAMPLES=OFF", "-DSDLTTF_VENDORED=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSDLTTF_HARFBUZZ=" .. (package:config("harfbuzz") and "ON" or "OFF"))
        table.insert(configs, "-DSDLTTF_PLUTOSVG=" .. (package:config("plutosvg") and "ON" or "OFF"))
        local freetype = package:dep("freetype")
        if freetype then
            local fetchinfo = freetype:fetch()
            if fetchinfo then
                local includedirs = table.wrap(fetchinfo.includedirs or fetchinfo.sysincludedirs)
                if #includedirs > 0 then
                    table.insert(configs, "-DFREETYPE_INCLUDE_DIRS=" .. table.concat(includedirs, ";"))
                end
                local libfiles = table.wrap(fetchinfo.libfiles)
                if #libfiles > 0 then
                    table.insert(configs, "-DFREETYPE_LIBRARY=" .. libfiles[1])
                end
                if not freetype:config("shared") then
                    local libfiles = {}
                    for _, dep in ipairs(freetype:librarydeps()) do
                        local depinfo = dep:fetch()
                        if depinfo then
                            table.join2(libfiles, depinfo.libfiles)
                        end
                    end
                    if #libfiles > 0 then
                        local libraries = ""
                        for _, libfile in ipairs(libfiles) do
                            libraries = libraries .. " " .. (libfile:gsub("\\", "/"))
                        end
                        io.replace("CMakeLists.txt", "target_link_libraries(${sdl3_ttf_target_name} PRIVATE Freetype::Freetype)",
                            "target_link_libraries(${sdl3_ttf_target_name} PRIVATE Freetype::Freetype " .. libraries .. ")", {plain = true})
                    end
                end
            end
        end
        import("package.tools.cmake").install(package, configs, {packagedeps={"plutovg"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TTF_Init", {includes = "SDL3_ttf/SDL_ttf.h"}))
    end)
