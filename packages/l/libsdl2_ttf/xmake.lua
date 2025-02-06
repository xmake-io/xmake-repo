package("libsdl2_ttf")
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

    add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).zip",
             "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-$(version).zip")

    add_versions("2.20.0", "04e94fc5ecac3475ab35c1d5cf52650df691867e7e4befcc861bf982a747111a")
    add_versions("2.20.1", "18d81ab399c8e39adababe8918691830ba6e0d6448e5baa141ee0ddf87ede2dc")
    add_versions("2.20.2", "aa6256bfcffd8381a75b3a2a2384ac12109b5b148e72722a19b0ede54c4051dc")
    add_versions("2.22.0", "5766070145111cb047807fa3f91c2c6b81bc1008d63817e100417959b42a2484")

    add_patches(">=2.20.0 <=2.20.1", path.join(os.scriptdir(), "patches", "2.20.1", "cmakelists.patch"), "fe04ada62d9ed70029c0efb3c04bfec22fc7596bd6b73a567beb964e61ebd82c")

    add_deps("cmake", "freetype")

    add_includedirs("include", "include/SDL2")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        package:add("deps", "libsdl2", { configs = { shared = package:config("shared") }})
    end)

    on_install(function (package)
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "sdl_find_sdl2(${sdl2_target_name} ${SDL_REQUIRED_VERSION})", "", {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(SDL2_ttf PRIVATE $<BUILD_INTERFACE:${sdl2_target_name}>)", [[
target_include_directories(SDL2_ttf PRIVATE ${SDL2_INCLUDE_DIR})
target_link_libraries(SDL2_ttf PRIVATE $<BUILD_INTERFACE:${SDL2_LIBRARY}>)
            ]], {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(SDL2_ttf PRIVATE ${sdl2_target_name})", [[
target_include_directories(SDL2_ttf PRIVATE ${SDL2_INCLUDE_DIR})
target_link_libraries(SDL2_ttf PRIVATE ${SDL2_LIBRARY})
            ]], {plain = true})
        end

        local configs = {"-DSDL2TTF_SAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSDL2TTF_VENDORED=OFF")
        local libsdl2 = package:dep("libsdl2")
        if libsdl2 and not libsdl2:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl2:installdir())
            local fetchinfo = libsdl2:fetch()
            if fetchinfo then
                for _, dir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    if os.isfile(path.join(dir, "SDL_version.h")) then
                        table.insert(configs, "-DSDL2_INCLUDE_DIR=" .. dir)
                        break
                    end
                end
                local libfiles = {}
                for _, libfile in ipairs(fetchinfo.libfiles) do
                    if libfile:match("SDL2%..+$") or libfile:match("SDL2-static%..+$") then
                        if not (package:config("shared") and libfile:endswith(".dll")) then
                            table.insert(libfiles, libfile)
                        end
                    end
                end
                table.insert(configs, "-DSDL2_LIBRARY=" .. table.concat(libfiles, ";"))
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
