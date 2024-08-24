package("libfido2")
    set_homepage("https://github.com/Yubico/libfido2")
    set_description("Provides library functionality for FIDO2, including communication with a device over USB or NFC.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Yubico/libfido2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Yubico/libfido2.git")

    add_versions("1.15.0", "32e3e431cfe29b45f497300fdb7076971cb77fc584fcfa80084d823a6ed94fbb")

    add_patches("1.15.0", "patches/1.15.0/cmake-pkgconfig-find-deps.patch", "efd904282b7ec321e984d03bf72a25e50c61ac9252c24f050a7b83daccb17a34")

    add_configs("hidapi", {description = "Use hidapi", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libfido2-devel")
    elseif is_plat("linux") then
        add_extsources("pacman::libfido2", "apt::libfido2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libfido2")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("setupapi", "hid", "bcrypt")
    end

    add_deps("cmake")
    if is_host("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("openssl", "libcbor", "zlib")

    on_load(function(package)
        if package:config("hidapi") then
            package:add("deps", "hidapi")
        end
    end)

    on_install("!iphoneos and !wasm", function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "-WX", "", {plain = true})

        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_MANPAGES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.join2(configs, {"-DBUILD_SHARED_LIBS=ON", "-DBUILD_STATIC_LIBS=OFF"})
        else
            table.join2(configs, {"-DBUILD_SHARED_LIBS=OFF", "-DBUILD_STATIC_LIBS=ON"})
        end

        table.insert(configs, "-DUSE_HIDAPI=" .. (package:config("hidapi") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        if package:is_plat("windows") then
            opt.cxflags = {"-D_CRT_SECURE_NO_WARNINGS", "-D_SCL_SECURE_NO_WARNINGS"}
            os.mkdir(path.join(package:buildir(), "src", "pdb"))
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fido_dev_new", {includes = "fido.h"}))
    end)
