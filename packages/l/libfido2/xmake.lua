package("libfido2")
    set_homepage("https://github.com/Yubico/libfido2")
    set_description("Provides library functionality for FIDO2, including communication with a device over USB or NFC.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Yubico/libfido2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Yubico/libfido2.git")

    add_versions("1.16.0", "7d86088ef4a48f9faad4ff6f41343328157849153a8dc94d88f4b5461cb29474")
    add_versions("1.15.0", "32e3e431cfe29b45f497300fdb7076971cb77fc584fcfa80084d823a6ed94fbb")

    add_patches("1.16.0", "patches/1.16.0/cmake-pkgconfig-find-deps.patch", "614a59325776a711cb259c94442e88498383c700f93197d0b7f5ae82b79e3a7d")
    add_patches("1.15.0", "patches/1.15.0/cmake-pkgconfig-find-deps.patch", "1d8c559529f8589e44f794b33d9216234d44ef857742db9ef94693dbd41c9486")

    add_patches(">=1.15.0", "patches/1.15.0/add-syslinks.patch", "1da25738d57afbb8c6b2a95796a9711d234a44903bc32e765377b2b455c340ee")

    add_configs("hidapi", {description = "Use hidapi", default = false, type = "boolean"})
    add_configs("pcsc", {description = "Enable experimental PCSC support", default = false, type = "boolean"})
    add_configs("windows_hello", {description = "Abstract Windows Hello as a FIDO device", default = false, type = "boolean"})
    add_configs("nfc", {description = "Enable NFC support on Linux", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("pacman::libfido2", "apt::libfido2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libfido2")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("setupapi", "hid", "bcrypt")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit")
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    add_deps("openssl", "libcbor", "zlib")
    if is_plat("linux") then
        add_deps("libudev")
    end

    on_load(function(package)
        if package:config("hidapi") then
            package:add("deps", "hidapi")
        end
        if package:config("pcsc") then
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "winscard")
            elseif package:is_plat("macosx") then
                package:add("frameworks", "PCSC")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "-WX", "", {plain = true})
        io.replace("CMakeLists.txt", "/sdl", "", {plain = true})

        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_MANPAGES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.join2(configs, {"-DBUILD_SHARED_LIBS=ON", "-DBUILD_STATIC_LIBS=OFF"})
        else
            table.join2(configs, {"-DBUILD_SHARED_LIBS=OFF", "-DBUILD_STATIC_LIBS=ON"})
        end
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DUSE_HIDAPI=" .. (package:config("hidapi") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_PCSC=" .. (package:config("pcsc") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_WINHELLO=" .. (package:config("windows_hello") and "ON" or "OFF"))
        table.insert(configs, "-DNFC_LINUX=" .. (package:config("nfc") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local openssl = package:dep("openssl")
        if not openssl:is_system() then
            table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fido_dev_new", {includes = "fido.h"}))
    end)
