package("snmalloc")
    set_homepage("https://github.com/microsoft/snmalloc")
    set_description("Message passing based allocator")
    set_license("MIT")

    add_urls("https://github.com/microsoft/snmalloc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/snmalloc.git")
    add_versions("0.6.0", "de1bfb86407d5aac9fdad88319efdd5593ca2f6c61fc13371c4f34aee0b6664f")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("onecore")
    end

    on_install("macosx", "windows", "linux", "bsd", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local cxflags
        if package:is_plat("windows") then
            cxflags = "/FS"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
        os.cp("src/snmalloc", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("snmalloc::DefaultPal::message(\"\")",
            {includes = "snmalloc/snmalloc.h", configs = {languages = "c++20", cxflags = "-mcx16"}}))
    end)
