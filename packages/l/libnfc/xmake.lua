package("libnfc")
    set_homepage("https://github.com/nfc-tools/libnfc")
    set_description("Header-only binary fuse and xor filter library.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/nfc-tools/libnfc/archive/refs/tags/libnfc-$(version).tar.gz", {alias = "tarball"})
    add_urls("https://github.com/nfc-tools/libnfc.git", {alias = "git"})
    add_versions("tarball:1.8.0", "0ab7d9b41442e7edc2af7c54630396edc73ce51128aa28a5c6e4135dc5595495")
    add_versions("tarball:1.7.1", "30de35b4f1af3f57dab40d91ffb2275664a35859ff2b014ba7b226aa3f5465f5")
    add_versions("git:1.8.0", "libnfc-1.8.0")
    add_versions("git:1.7.1", "libnfc-1.7.1")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_configs("logging",      {description = "Enable log facility. (errors, warning, info and debug messages)", default = true, type = "boolean"})
    add_configs("envvars",      {description = "Enable envvars facility.", default = true, type = "boolean"})
    add_configs("configurable", {description = "Enable configuration files.", default = true, type = "boolean"})

    -- drivers
    add_configs("pcsc",         {description = "Enable PC/SC reader support (Depends on PC/SC)", default = false, type = "boolean"})
    add_configs("acr122_pcsc",  {description = "Enable ACR122 support (Depends on PC/SC)", default = false, type = "boolean"})
    add_configs("acr122_usb",   {description = "Enable ACR122 support (Direct USB connection)", default = true, type = "boolean"})
    add_configs("acr122s",      {description = "Enable ACR122S support (Use serial port)", default = true, type = "boolean"})
    add_configs("arygon",       {description = "Enable ARYGON support (Use serial port)", default = true, type = "boolean"})
    add_configs("pn532_i2c",    {description = "Enable PN532 I2C support (Use I2C bus)", default = is_plat("linux"), type = "boolean"})
    add_configs("pn532_spi",    {description = "Enable PN532 SPI support (Use SPI bus)", default = is_plat("linux"), type = "boolean"})
    add_configs("pn532_uart",   {description = "Enable PN532 UART support (Use serial port)", default = true, type = "boolean"})
    add_configs("pn53x_usb",    {description = "Enable PN531 and PN531 USB support (Depends on libusb)", default = true, type = "boolean"})

    if not is_plat("bsd") then
        if not is_plat("windows", "mingw", "msys", "cygwin") then
            add_deps("libusb-compat")
        else
            add_deps("libusb-win32")
            add_syslinks("wsock32")
        end
    end

    add_deps("cmake")
    if not is_subhost("windows") then
        add_deps("pkg-config")
    else
        add_deps("pkgconf")
    end

    on_check("!linux", function (package)
        assert(not package:config("pn532_i2c") and not package:config("pn532_spi"), "package(libnfc): I2C/SPI is only (yet) supported in Linux!")
    end)

    on_load(function (package)
        if package:config("pcsc") or package:config("acr122_pcsc") then
            if package:is_plat("linux", "bsd") then
                package:add("deps", "libpcsclite")
            end
        end
        if package:version():le("1.7.1") and package:is_plat("windows", "mingw", "msys", "cygwin") then
            package:add("deps", "pcre")
        end
    end)

    -- about windows:
    -- @see https://github.com/nfc-tools/libnfc/pull/734
    on_install("!iphoneos and !wasm and !windows", function (package)
        local configs = {
            "-DBUILD_UTILS=OFF",
            "-DBUILD_EXAMPLES=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))

        table.insert(configs, "-DLIBNFC_LOG=" .. (package:config("logging") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_ENVVARS=" .. (package:config("envvars") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_CONFFILES_MODE=" .. (package:config("configurable") and "ON" or "OFF"))

        table.insert(configs, "-DLIBNFC_DRIVER_PCSC=" .. (package:config("pcsc") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ACR122_PCSC=" .. (package:config("acr122_pcsc") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ACR122_USB=" .. (package:config("acr122_usb") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ACR122S=" .. (package:config("acr122s") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ARYGON=" .. (package:config("arygon") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN532_I2C=" .. (package:config("pn532_i2c") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN532_SPI=" .. (package:config("pn532_spi") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN532_UART=" .. (package:config("pn532_uart") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN53X_USB=" .. (package:config("pn53x_usb") and "ON" or "OFF"))

        if package:is_plat("windows", "mingw", "msys", "cygwin") then
            local usb = package:dep("libusb-win32")
            if usb then
                local fetchinfo = usb:fetch()
                if fetchinfo then
                    local includedirs = table.wrap(fetchinfo.includedirs or fetchinfo.sysincludedirs)
                    if #includedirs > 0 then
                        table.insert(configs, "-DLIBUSB_INCLUDE_DIRS=" .. table.concat(includedirs, ";"))
                    end
                    local libfiles = table.wrap(fetchinfo.libfiles)
                    if #libfiles > 0 then
                        table.insert(configs, "-DLIBUSB_LIBRARIES=" .. libfiles[1])
                    end
                end
            end
        end
        if package:is_plat("mingw") then
            table.insert(configs, "-DDLLTOOL=" .. package:tool("dlltool"))
            if package:version():le("1.7.1") then
                io.replace("libnfc/CMakeLists.txt", "dlltool", "${DLLTOOL}", {plain = true})
            end
        end
        local opts = {}
        if package:is_plat("macosx") then
            opts.shflags = {"-framework", "CoreFoundation", "-framework", "IOKit", "-framework", "Security"}
        end
        if package:is_plat("windows", "mingw", "msys", "cygwin") then
            opts.cflags = [[-DSYSCONFDIR="./config"]]
            io.replace("CMakeLists.txt", "FIND_PACKAGE(PCRE REQUIRED)", [[
                find_package(PkgConfig REQUIRED)
                pkg_check_modules(PCRECORE REQUIRED libpcre)
                pkg_check_modules(PCRE REQUIRED libpcreposix)
                add_compile_options(${PCRE_CFLAGS})
            ]], {plain = true})
            io.replace("libnfc/CMakeLists.txt", "${PCRE_LIBRARIES}", "${PCRE_LIBRARIES} ${PCRECORE_LIBRARIES}", {plain = true})
            io.replace("libnfc/conf.c", "#include <regex.h>", "#include <pcreposix.h>", {plain = true})
        end
        if package:version():le("1.7.1") then
            io.replace("CMakeLists.txt", "# version.rc for Windows\nIF(WIN32)", "IF(0)", {plain = true})
            io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY(utils)", "", {plain = true})
            io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY(examples)", "", {plain = true})
        end
        io.replace("CMakeLists.txt", [[CMAKE_SYSTEM_PROCESSOR STREQUAL "x86"]], [[CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86|i[3-6]86)$"]], {plain = true})
        io.replace("libnfc/CMakeLists.txt", [[LIST(APPEND WINDOWS_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/../windows/libnfc.rc)]], "", {plain = true})
        io.replace("libnfc/CMakeLists.txt", "DESTINATION bin", "DESTINATION ${CMAKE_INSTALL_LIBDIR}", {plain = true})
        io.replace("cmake/modules/FindLIBUSB.cmake", "PKG_CHECK_MODULES(LIBUSB REQUIRED libusb)", "PKG_CHECK_MODULES(LIBUSB REQUIRED libusb-compat)", {plain = true})
        io.replace("contrib/win32/stdlib.c", "char *str[32];", "char str[32];", {plain = true})

        io.replace("CMakeLists.txt", "INCLUDE(UseDoxygen)", "", {plain = true})
        import("package.tools.cmake").install(package, configs, opts)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nfc_version", {configs = {languages = "c99"}, includes = "nfc/nfc.h"}))
    end)
