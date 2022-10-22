package("zip")
    set_homepage("https://github.com/kuba--/zip")
    set_description("A portable (OSX/Linux/Windows/Android/iOS), simple zip library written in C")
    set_license("Unlicense license")
    
    add_urls("https://github.com/kuba--/zip/archive/refs/tags/v$(version).zip",
            "https://github.com/kuba--/zip.git")
    add_versions("0.2.5", "7a57414261361ca991ff8053881343eb6bb6f205")    
    
    add_deps("cmake")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DCMAKE_DISABLE_TESTING=ON", "-DZIP_BUILD_DOCS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)


    on_test(function (package)
        assert(package:has_cfuncs("zip_open", {includes = "zip/zip.h"}))
    end)