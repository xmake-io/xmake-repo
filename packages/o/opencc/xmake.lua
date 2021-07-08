package("opencc")

    set_homepage("https://github.com/BYVoid/OpenCC")
    set_description("Conversion between Traditional and Simplified Chinese.")

    set_urls("https://github.com/BYVoid/OpenCC/archive/ver.$(version).zip")
    add_versions("1.1.2", "b4a53564d0de446bf28c8539a8a17005a3e2b1877647b68003039e77f8f7d9c2")

    add_deps("cmake")

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {"-DBUILD_DOCUMENTATION=OFF", "-DENABLE_GTEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("static") then
            os.cp("build/deps/marisa-0.2.6/*.a", package:installdir("lib"))
        end
    end)

    on_install("windows", "mingw", function (package)
        local configs = {"-DBUILD_DOCUMENTATION=OFF", "-DENABLE_GTEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
        if package:config("static") then
            os.cp("build/deps/marisa-0.2.6/" .. (package:debug() and "Debug" or "Release") .. "/*.lib", package:installdir("lib"))
        end
    end)

    on_test("windows", "mingw", "linux", "macosx", "bsd", function (package)
        local configs = {includes = "opencc/opencc.h"}
        if package:config("static") then
            configs.ldflags = "-lmarisa"
        end
        assert(package:has_cfuncs("opencc_open", configs))
    end)
