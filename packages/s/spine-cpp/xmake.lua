package("spine-cpp")
    set_homepage("https://github.com/EsotericSoftware/spine-runtimes")
    set_description("Spine runtimes for C++")
    set_license("Spine Runtimes")

    add_urls("https://github.com/EsotericSoftware/spine-runtimes.git")

    add_versions("3.8","d33c10f85634d01efbe4a3ab31dabaeaca41230c")
    add_patches("3.8","./3.8.patch")

    if is_plat("windows") then
        set_policy("platform.longpaths", true)
    end

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package)
        os.cp("./include", package:installdir())
        os.cp("./lib", package:installdir())
    end)
    on_test(function (package)
        assert(package:has_cxxincludes("spine/spine.h"))
    end)
