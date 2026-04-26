package("liblo")
    set_homepage("https://github.com/radarsat1/liblo")
    set_description("An implementation of the Open Sound Control protocol for POSIX systems")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/radarsat1/liblo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/radarsat1/liblo.git")
    add_versions("0.34", "e9a294c7613e1bec2abcf26f2010604643d605ed6852e16b51837400729fcbee")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux", "cross", "bsd") then
        add_syslinks("pthread", "m")
    elseif is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32", "iphlpapi")
    end

    on_install(function (package)
        os.cd("cmake")
        local configs = {
            "-DWITH_STATIC=ON",
            "-DWITH_TESTS=OFF",
            "-DWITH_EXAMPLES=OFF",
            "-DWITH_CPP_TESTS=OFF"
        }
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            io.replace("CMakeLists.txt", [[TARGETS ${LIBRARY_STATIC} ${LIBRARY_SHARED}]], [[TARGETS ${LIBRARY_SHARED}]], {plain = true})
        else
            io.replace("CMakeLists.txt", [[TARGETS ${LIBRARY_STATIC} ${LIBRARY_SHARED}]], [[TARGETS ${LIBRARY_STATIC}]], {plain = true})
        end
        io.replace("CMakeLists.txt", [[add_library(${LIBRARY_STATIC} STATIC ${LIBRARY_SOURCES})]], [[add_library(${LIBRARY_STATIC} STATIC ${LIBRARY_SOURCES})
    if (BUILD_SHARED_LIBS)
        set_target_properties(${LIBRARY_STATIC} PROPERTIES EXCLUDE_FROM_ALL 1)
    else()
        set_target_properties(${LIBRARY_SHARED} PROPERTIES EXCLUDE_FROM_ALL 1)
    endif()]], {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lo_address_new", {includes = "lo/lo.h"}))
    end)
