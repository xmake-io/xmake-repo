package("capstone")
    set_homepage("http://www.capstone-engine.org")
    set_description("Disassembly framework with the target of becoming the ultimate disasm engine for binary analysis and reversing in the security community.")
    add_urls("https://github.com/aquynh/capstone/archive/$(version).tar.gz")

    add_versions("4.0.2", "7c81d798022f81e7507f1a60d6817f63aa76e489aa4e7055255f21a22f5e526a")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::capstone")
    elseif is_plat("linux") then
        add_extsources("pacman::capstone", "apt::libcapstone-dev")
    elseif is_plat("macosx")then
        add_extsources("brew::capstone")
    end
    
    add_deps("cmake")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", "msys", "bsd", function (package)
        local configs = {"-DCAPSTONE_BUILD_CSTOOL=ON", "-DCAPSTONE_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCAPSTONE_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCAPSTONE_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        io.gsub("CMakeLists.txt", "CAPSTONE_BUILD_SHARED AND CAPSTONE_BUILD_CSTOOL", "CAPSTONE_BUILD_CSTOOL")
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        if package:is_plat(os.host()) then
            os.vrun("cstool -v")
        end
        assert(package:has_cfuncs("cs_version", {includes = "capstone/capstone.h"}))
    end)