package("libdatachannel")
    add_deps("cmake", "openssl")
    add_urls("https://github.com/paullouisageneau/libdatachannel.git", {submodules = true})
    add_versions("v0.23.1", "222529eb2c8ae44f96462504ae38023f62809cec")
    on_install(function (package)
        local configs = {}

        io.replace("CMakeLists.txt", "install(FILES $<TARGET_PDB_FILE:datachannel>", "message(")

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOPENSSL_USE_STATIC_LIBS=ON")
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:has_cfuncs("rtcSetUserPointer", {includes = "rtc/rtc.h"}))
    end)
package_end()
