package("bullet3")

    set_homepage("http://bulletphysics.org")
    set_description("Bullet Physics SDK.")

    set_urls("https://github.com/bulletphysics/bullet3/archive/$(version).zip",
             "https://github.com/bulletphysics/bullet3.git")
    add_versions("2.88", "f361d10961021a186b80821cfc1cfafc8dac48ce35f7d5e8de0943af4b3ddce4")

    add_deps("cmake")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DBUILD_CPU_DEMOS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("btVector3(0,0,0)", {includes = "bullet/LinearMath/btVector3.h"}))
    end)
