package("backward-cpp")

    set_homepage("https://github.com/bombela/backward-cpp")
    set_description("Backward is a beautiful stack trace pretty printer for C++.")
    set_license("MIT")

    add_urls("https://github.com/bombela/backward-cpp/archive/refs/tags/$(version).zip",
             "https://github.com/bombela/backward-cpp.git")
    add_versions("v1.6", "9b07e12656ab9af8779a84e06865233b9e30fadbb063bf94dd81d318081db8c2")

    add_deps("cmake")

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-DBACKWARD_TESTS=OFF"}
        table.insert(configs, "-DBACKWARD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").build(package, configs, {buildir = "build"})

        os.cp("backward.hpp", package:installdir("include/backward"))
        if package:is_plat("windows") then
            os.trycp("build/**.dll", package:installdir("bin"))
            os.trycp("build/**.lib", package:installdir("lib"))
        else
            os.trycp("build/*.so", package:installdir("lib"))
            os.trycp("build/*.a", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("backward::SignalHandling", {configs = {languages = "c++11"}, includes = "backward/backward.hpp"}))
    end)
