package("libflac")
    set_homepage("https://xiph.org/flac")
    set_description("Free Lossless Audio Codec")
    set_license("BSD")

    set_urls("https://github.com/xiph/flac/archive/$(version).tar.gz",
             "https://github.com/xiph/flac.git")

    add_versions("1.5.0", "aea54ed186ad07a34750399cb27fc216a2b62d0ffcd6dc2e3064a3518c3146f8")
    add_versions("1.4.3", "0a4bb82a30609b606650d538a804a7b40205366ce8fc98871b0ecf3fbb0611ee")
    add_versions("1.4.2", "8e8e0406fb9e1d177bb4ba8cfed3ca3935d37144eac8f0219a03e8c1ed5cc18e")
    add_versions("1.3.3", "668cdeab898a7dd43cf84739f7e1f3ed6b35ece2ef9968a5c7079fe9adfe1689")
    
    add_patches("1.5.0", "patches/1.5.0/fix-cmake-in.patch", "326971747da526e18fa47e86cd127f2f3a80b9f85ac8f214a238c2456849be83")
    add_patches("1.5.0", "patches/1.5.0/cmake.patch", "6ce0ff5c6e8be0a68d4abaf9c0801f988f5cb600228ee9e2db812adf6e4cf3c1")
    add_patches("1.4.3", "patches/1.4.2/cmake.patch", "0a99382d5d7bd33078572b6cc3af08ee7e5e3618c80754a5fdc400bd69f4e470")
    add_patches("1.4.2", "patches/1.4.2/cmake.patch", "0a99382d5d7bd33078572b6cc3af08ee7e5e3618c80754a5fdc400bd69f4e470")
    add_patches("1.3.3", "patches/1.3.3/cmake.patch", "49baa40ab70d63e74cfc3f0cc2f13824545a618ceaeffdd51d3333d90b37fd32")

    if is_plat("android") then
        add_patches("1.5.0", "patches/1.5.0/android_fseek.diff", "75377f3a309094d91ff2e56727df09a00baa23cbec44b03193253cfec9b5324a")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::flac")
    elseif is_plat("linux") then
        add_extsources("pacman::flac", "apt::libflac++-dev", "apt::libflac-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::flac")
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "libogg")

    if is_plat("linux") then
        add_syslinks("m")
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "FLAC__NO_DLL")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_CXXLIBS=OFF")
        table.insert(configs, "-DBUILD_DOCS=OFF")
        table.insert(configs, "-DBUILD_PROGRAMS=OFF")
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DBUILD_UTILS=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        table.insert(configs, "-DINSTALL_MANPAGES=OFF")
        if package:is_plat("wasm") then
            -- wasm doesn't support stack protector
            table.insert(configs, "-DWITH_STACK_PROTECTOR=OFF")
        end

        -- fix, undefined reference to `__memset_chk'
        -- @see https://github.com/msys2/MINGW-packages/issues/5803
        if package:config("shared") and package:is_plat("mingw") then
            io.replace("CMakeLists.txt", "add_definitions(-DHAVE_CONFIG_H)", "add_definitions(-DHAVE_CONFIG_H -D_FORTIFY_SOURCE=0)", {plain = true})
        end

        -- we pass libogg as packagedeps instead of findOgg.cmake (it does not work)
        local libogg = package:dep("libogg"):fetch()
        if libogg then
            local links = table.concat(table.wrap(libogg.links), " ")
            io.replace("CMakeLists.txt", "find_package(OGG REQUIRED)", "", {plain = true}) -- v1.3.3
            io.replace("CMakeLists.txt", "find_package(Ogg REQUIRED)", "", {plain = true}) -- v1.3.4+
            io.replace("src/libFLAC/CMakeLists.txt",
            [[
if(TARGET Ogg::ogg)
    target_link_libraries(FLAC PUBLIC Ogg::ogg)
endif()]], "target_link_libraries(FLAC PUBLIC " .. links .. ")", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "libogg"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FLAC__format_sample_rate_is_valid", {includes = "FLAC/format.h"}))
    end)
