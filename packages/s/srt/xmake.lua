package("srt")

    set_homepage("https://www.srtalliance.org/")
    set_description("Secure Reliable Transport (SRT) Protocol")
    set_license("MPL-2.0")

    add_urls("https://github.com/Haivision/srt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Haivision/srt.git")
    add_versions("v1.5.4", "d0a8b600fe1b4eaaf6277530e3cfc8f15b8ce4035f16af4a5eb5d4b123640cdd")
    add_versions("v1.5.3", "befaeb16f628c46387b898df02bc6fba84868e86a6f6d8294755375b9932d777")
    add_versions("v1.4.2", "28a308e72dcbb50eb2f61b50cc4c393c413300333788f3a8159643536684a0c4")

    add_deps("cmake")
    add_deps("openssl")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"-DENABLE_APPS=OFF", "-DENABLE_TESTING=OFF", "-DENABLE_UNITTESTS=OFF"}
        table.insert(configs, "-DENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        io.replace("CMakeLists.txt", "install(PROGRAMS scripts/srt-ffplay DESTINATION ${CMAKE_INSTALL_BINDIR})", "", {plain = true})
        table.insert(configs, "-DCMAKE_INSTALL_INCLUDEDIR=" .. package:installdir("include"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("srt_startup", {includes = "srt/srt.h"}))
    end)

