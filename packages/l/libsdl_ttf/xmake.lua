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

    if is_plat("windows", "mingw") then
        add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).zip",
                 "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-$(version).zip", { alias = "archive" })
        add_versions("archive:2.20.0", "04e94fc5ecac3475ab35c1d5cf52650df691867e7e4befcc861bf982a747111a")
        add_versions("archive:2.20.1", "18d81ab399c8e39adababe8918691830ba6e0d6448e5baa141ee0ddf87ede2dc")
        add_versions("archive:2.20.2", "aa6256bfcffd8381a75b3a2a2384ac12109b5b148e72722a19b0ede54c4051dc")
    else
        add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).tar.gz",
                 "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-$(version).tar.gz", { alias = "archive" })
        add_versions("archive:2.20.0", "874680232b72839555a558b48d71666b562e280f379e673b6f0c7445ea3b9b8a")
        add_versions("archive:2.20.1", "78cdad51f3cc3ada6932b1bb6e914b33798ab970a1e817763f22ddbfd97d0c57")
        add_versions("archive:2.20.2", "9dc71ed93487521b107a2c4a9ca6bf43fb62f6bddd5c26b055e6b91418a22053")
    end
    add_urls("https://github.com/libsdl-org/SDL_ttf.git", { alias = "github" })
    --add_versions("github:2.0.8",  "release-2.0.8")
    --add_versions("github:2.0.9",  "release-2.0.9")
    --add_versions("github:2.0.10",  "release-2.0.10")
    --add_versions("github:2.0.11",  "release-2.0.11")
    --add_versions("github:2.0.12",  "release-2.0.12")
    --add_versions("github:2.0.13",  "release-2.0.13")
    --add_versions("github:2.0.14",  "release-2.0.14")
    --add_versions("github:2.0.15",  "release-2.0.15")
    --add_versions("github:2.0.18",  "release-2.0.18")
    add_versions("github:2.20.0",  "release-2.20.0")
    add_versions("github:2.20.1",  "release-2.20.1")
    add_versions("github:2.20.2",  "release-2.20.2")
    --add_versions("github:2.22.0",  "release-2.22.0")

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
        table.insert(configs, "-DSDL2TTF_VENDORED=OFF")
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
        assert(package:check_cxxsnippets({test = [[
            #include <SDL2/SDL.h>
            #include <SDL2/SDL_ttf.h>
            int main(int argc, char** argv) {
                TTF_Init();
                TTF_Quit();
                return 0;
            }
        ]]}, {configs = {defines = "SDL_MAIN_HANDLED"}}));
    end)
