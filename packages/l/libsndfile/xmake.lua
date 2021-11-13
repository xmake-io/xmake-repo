package("libsndfile")

    set_homepage("https://libsndfile.github.io/libsndfile/")
    set_description("A C library for reading and writing sound files containing sampled audio data.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libsndfile/libsndfile/archive/$(version).tar.gz",
             "https://github.com/libsndfile/libsndfile.git")
    add_versions("v1.0.30", "5942b963d1db3ed8ab1ffb85708322aa9637df76d9fe84e1dfe49a97a90e8f47")
    add_versions("1.0.31", "a8cfb1c09ea6e90eff4ca87322d4168cdbe5035cb48717b40bf77e751cc02163")

    add_deps("cmake", "libflac", "libopus", "libvorbis", "libogg")

    on_load("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        if package:config("shared") then
            package:add("deps", "python 3.x", {kind = "binary"})
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_PROGRAMS=OFF")
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:is_plat("windows") then

            -- libsndfile doesn't build well with a static libFLAC, this fixes it
            if not package:dep("libflac"):config("shared") then
                local cmake = io.open("CMakeLists.txt", "a")
                cmake:write("add_definitions(-DFLAC__NO_DLL)\n")
                cmake:close()
            end
        end
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:has_cfuncs("sf_version_string", {includes = "sndfile.h"}))
    end)
