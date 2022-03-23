package("pthreadpool")

    set_homepage("https://github.com/Maratyszcza/pthreadpool")
    set_description("Portable (POSIX/Windows/Emscripten) thread pool for C/C++")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Maratyszcza/pthreadpool.git")
    add_versions("2021.05.08", "1787867f6183f056420e532eec640cba25efafea")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "fxdiv")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_install("windows", "macosx", "linux", function (package)
        io.gsub("CMakeLists.txt", "IF%(NOT TARGET fxdiv%).-ENDIF%(%)", "add_library(fxdiv INTERFACE)\ntarget_include_directories(fxdiv INTERFACE \"${FXDIV_SOURCE_DIR}/include\")")
        local configs = {"-DPTHREADPOOL_BUILD_TESTS=OFF", "-DPTHREADPOOL_BUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local fxdiv = package:dep("fxdiv")
        if fxdiv and not fxdiv:is_system() then
            table.insert(configs, "-DFXDIV_SOURCE_DIR=" .. fxdiv:installdir())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pthreadpool_create", {includes = "pthreadpool.h"}))
    end)
