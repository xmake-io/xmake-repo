package("yasm")

    set_kind("binary")
    set_homepage("https://yasm.tortall.net/")
    set_description("Modular BSD reimplementation of NASM.")

    add_urls("https://www.tortall.net/projects/yasm/releases/yasm-$(version).tar.gz",
             "https://ftp.openbsd.org/pub/OpenBSD/distfiles/yasm-$(version).tar.gz")
    add_versions("1.3.0", "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f")
    add_patches("1.3.0", path.join(os.scriptdir(), "patches", "fix-bool-gcc15.diff"), "bc58964451aec9495e1bd4ebb8f6a035dc7b01be6a041cba3fcf90decba7d6e1")
    add_patches("1.3.0", path.join(os.scriptdir(), "patches", "upd-min-cmake.diff"), "5c234e51f03502970104027f1580b733d89109144b85ee0b3b5366febab28623")

    add_deps("cmake")
    add_deps("python 3.x", {kind = "binary"})

    on_install("@windows", "@linux", "@macosx", "@mingw", "@msys", function (package)
        local configs = {"-DYASM_BUILD_TESTS=OFF", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("mingw") then
            io.replace("frontends/yasm/yasm-plugin.c", "#if defined(_WIN32)", "#if 1", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("yasm --version")
    end)
    