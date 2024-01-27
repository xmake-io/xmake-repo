package("dcmtk")

    set_homepage("https://dcmtk.org/dcmtk.php.en")
    set_description("DCMTK - DICOM Toolkit")
    set_license("BSD-3-Clause")

    add_urls("https://dicom.offis.de/download/dcmtk/dcmtk$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "") .. "/dcmtk-" .. version
    end})
    add_versions("3.6.6", "6859c62b290ee55677093cccfd6029c04186d91cf99c7642ae43627387f3458e")

    local configdeps = {libtiff    = "TIFF",
                        libpng     = "PNG",
                        openssl    = "OPENSSL",
                        libxml2    = "XML",
                        zlib       = "ZLIB",
                        libsndfile = "SNDFILE",
                        libiconv   = "ICONV",
                        icu4c      = "ICU",
                        openjpeg   = "OPENJPEG"}
    for config, _ in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = (config ~= "openssl" and config ~= "icu4c"), type = "boolean"})
    end

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("ws2_32", "netapi32")
    end
    on_load("windows", "macosx", "linux", function (package)
        for config, _ in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
        if package:config("libtiff") then
            package:add("deps", "libjpeg-turbo")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMake/3rdparty.cmake", "OpenJPEG QUIET", "OpenJPEG CONFIG QUIET", {plain = true})
        io.replace("CMake/3rdparty.cmake", "include_directories(${LIBXML2_INCLUDE_DIR})", "include_directories(${LIBXML2_INCLUDE_DIR})\nadd_definitions(-DLIBXML_STATIC)", {plain = true})
        local configs = {"-DDCMTK_USE_FIND_PACKAGE=ON", "-DDCMTK_WITH_WRAP=OFF", "-DDCMTK_WITH_DOXYGEN=OFF", "-DDCMTK_ENABLE_MANPAGES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DDCMTK_COMPILE_WIN32_MULTITHREADED_DLL=" .. ((package:config("runtimes") and package:has_runtime("MD", "MDd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MD")) and "ON" or "OFF"))
        elseif package:config("pic") ~= false then
            table.insert(configs, "-DDCMTK_FORCE_FPIC_ON_UNIX=ON")
        end
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DDCMTK_WITH_" .. dep .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "dcmtk/config/osconfig.h"
            #include "dcmtk/ofstd/ofcmdln.h"
            void test() {
                OFCommandLine cmd;
                cmd.setOptionColumns(20, 3);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
