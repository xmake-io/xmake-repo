package("libusb")
    set_homepage("https://libusb.info")
    set_description("A cross-platform library to access USB devices ")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libusb/libusb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libusb/libusb.git")

    add_versions("v1.0.29", "7c2dd39c0b2589236e48c93247c986ae272e27570942b4163cb00a060fcf1b74")
    add_versions("v1.0.28", "378b3709a405065f8f9fb9f35e82d666defde4d342c2a1b181a9ac134d23c6fe")
    add_versions("v1.0.27", "e8f18a7a36ecbb11fb820bd71540350d8f61bcd9db0d2e8c18a6fb80b214a3de")
    add_versions("v1.0.26", "a09bff99c74e03e582aa30759cada218ea8fa03580517e52d463c59c0b25e240")

    add_resources(">=1.0.26", "libusb-cmake", "https://github.com/libusb/libusb-cmake.git", "8f0b4a38fc3eefa2b26a99dff89e1c12bf37afd4")

    if is_plat("macosx") then
        add_extsources("brew::libusb")
    elseif is_plat("linux") then
        add_extsources("apt::libusb-dev", "pacman::libusb")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libusb")
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit", "Security")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    if is_plat("linux", "cross") then
        add_deps("eudev")
    end

    add_includedirs("include", "include/libusb-1.0")
    -- https://github.com/emscripten-core/emscripten/issues/13017
    if is_plat("wasm") then
        add_ldflags("--bind", "-s ASYNCIFY=1")
    end

    on_install("!iphoneos", function (package)
        local dir = package:resourcefile("libusb-cmake")
        os.cp(path.join(dir, "CMakeLists.txt"), os.curdir())
        os.cp(path.join(dir, "config.h.in"), os.curdir())
        io.replace("CMakeLists.txt",
            [[get_filename_component(LIBUSB_ROOT "libusb/libusb" ABSOLUTE)]],
            [[get_filename_component(LIBUSB_ROOT "libusb" ABSOLUTE)]], {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local packagedeps = {}
        if package:is_plat("linux", "cross") then
            table.insert(packagedeps, "eudev")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libusb_init", {includes = "libusb-1.0/libusb.h"}))
    end)
