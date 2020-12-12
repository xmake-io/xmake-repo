package("libsndfile")

    set_homepage("https://libsndfile.github.io/libsndfile/")
    set_description("A C library for reading and writing sound files containing sampled audio data.")
    set_license("LGPL-2.1")

    set_urls("https://github.com/libsndfile/libsndfile/archive/v$(version).tar.gz",
             "https://github.com/libsndfile/libsndfile.git")

    add_versions("1.0.30", "5942b963d1db3ed8ab1ffb85708322aa9637df76d9fe84e1dfe49a97a90e8f47")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {"-DBUILD_PROGRAMS=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime == "MT" then
                table.insert(configs, "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded")
            elseif vs_runtime == "MTd" then
                table.insert(configs, "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug")
            elseif vs_runtime == "MD" then
                table.insert(configs, "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL")
            elseif vs_runtime == "MDd" then
                table.insert(configs, "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebugDLL")
            end
       end

        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const char* version = sf_version_string();
            }
        ]]}, {includes = {"sndfile.h"}}))
    end)
