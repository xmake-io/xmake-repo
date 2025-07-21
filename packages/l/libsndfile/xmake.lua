package("libsndfile")
    set_homepage("https://libsndfile.github.io/libsndfile/")
    set_description("A C library for reading and writing sound files containing sampled audio data.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libsndfile/libsndfile/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libsndfile/libsndfile.git")

    add_versions("1.2.2", "ffe12ef8add3eaca876f04087734e6e8e029350082f3251f565fa9da55b52121")
    add_versions("1.0.31", "8cdee0acb06bb0a3c1a6ca524575643df8b1f3a55a0893b4dd9f829d08263785")

    add_patches("1.2.2", "patches/1.2.2/do-not-install-find.diff", "008f66254b7d0f7602b3c6153a0e9b2c74395c9e9cc0e2e75784a6ed8eb23209")
    add_patches("1.2.2", "patches/1.2.2/do-not-set-cmake-module-path.diff", "d59b50d14dca44485aae56ae27456779b0a38c0cfec9785bab500d31cf35188e")

    add_deps("cmake")
    add_deps("libflac", "libopus", "libvorbis", "libogg")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        if package:config("shared") then
            package:add("deps", "python 3.x", {kind = "binary"})
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        -- we pass libogg as packagedeps instead of findOgg.cmake (it does not work)
        io.replace("cmake/SndFileChecks.cmake", [[find_package (Ogg 1.3 CONFIG)]], [[]], {plain = true})
        local configs = {
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
        }
        table.insert(configs, "-DBUILD_PROGRAMS=OFF")
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_MPEG=OFF")

        if package:is_plat("windows", "mingw") then
            -- libsndfile doesn't build well with a static libFLAC, this fixes it
            if not package:dep("libflac"):config("shared") then
                local cmake = io.open("CMakeLists.txt", "a")
                cmake:write("add_definitions(-DFLAC__NO_DLL)\n")
                cmake:close()
            end
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "libogg"})
   end)

    on_test(function (package)
        assert(package:has_cfuncs("sf_version_string", {includes = "sndfile.h"}))
    end)
