package("libsdl_ttf")
    set_homepage("https://github.com/libsdl-org/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_ttf")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_ttf", "apt::libsdl2-ttf-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_ttf")
    end

    add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).tar.gz",
             "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-$(version).tar.gz")
    add_versions("2.20.0", "874680232b72839555a558b48d71666b562e280f379e673b6f0c7445ea3b9b8a")
    add_versions("2.20.1", "78cdad51f3cc3ada6932b1bb6e914b33798ab970a1e817763f22ddbfd97d0c57")
    add_versions("2.20.2", "9dc71ed93487521b107a2c4a9ca6bf43fb62f6bddd5c26b055e6b91418a22053")

    add_patches(">=2.20.0 <=2.20.1", path.join(os.scriptdir(), "patches", "2.20.1", "cmakelists.patch"), "fe04ada62d9ed70029c0efb3c04bfec22fc7596bd6b73a567beb964e61ebd82c")

    add_deps("cmake", "freetype")

    add_includedirs("include", "include/SDL2")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libsdl", { configs = { shared = true }})
        else
            package:add("deps", "libsdl")
        end
    end)

    on_install(function (package)
        local configs = {"-DSDL2TTF_SAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local libsdl = package:dep("libsdl")
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
            local fetchinfo = libsdl:fetch()
            if fetchinfo then
                for _, dir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    if os.isfile(path.join(dir, "SDL_version.h")) then
                        table.insert(configs, "-DSDL2_INCLUDE_DIR=" .. dir)
                        break
                    end
                end
                for _, libfile in ipairs(fetchinfo.libfiles) do
                    if libfile:match("SDL2%..+$") or libfile:match("SDL2-static%..+$") then
                        table.insert(configs, "-DSDL2_LIBRARY=" .. libfile)
                    end
                end
            end
        end
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
                        io.replace("CMakeLists.txt", "target_link_libraries(SDL2_ttf PRIVATE Freetype::Freetype)",
                            "target_link_libraries(SDL2_ttf PRIVATE Freetype::Freetype " .. libraries .. ")", {plain = true})
                    end
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TTF_Init",
            {includes = "SDL2/SDL_ttf.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
