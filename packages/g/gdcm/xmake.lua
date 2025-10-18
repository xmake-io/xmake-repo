package("gdcm")
    set_homepage("http://sf.net/p/gdcm")
    set_description("Grassroots DiCoM is a C++ library for DICOM medical files.")
    set_license("BSD License, Apache License V2.0")

    add_urls("https://github.com/malaterre/GDCM/archive/refs/tags/$(version).tar.gz",
             "https://github.com/malaterre/GDCM.git")
    add_versions("v3.2.2", "133078bfff4fe850a1faaea44b0a907ba93579fd16f34c956f4d665b24b590e5")
    add_versions("v3.2.1", "63d4fbbb487d450bc8004542892a45349bdc9f4400f7010c07170c127ef0f9e3")
    add_versions("v3.0.24", "d88519a094797c645ca34797a24a14efc10965829c4c3352c8ef33782a556336")
    add_patches(">3.0", "patches/cmake.patch", "2583f0f0beb829f7c67bc2ee56f1d976245153aa006973f89e5bc42e659afea6")

    add_deps("cmake", "charls", "expat", "openjpeg", "pkgconf", "zlib")

    local configdeps = {["json-c"] = "JSON",
                        libxml2    = "LIBXML2",
                        poppler    = "POPPLER",
    }
    for config, _ in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = false, type = "boolean"})
    end

    if is_plat("windows") then
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_extsources("apt::libgdcm-dev", "pacman::gdcm")
    elseif is_plat("macosx") then
        add_extsources("brew::gdcm")
        add_frameworks("CoreFoundation")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::gdcm")
    end

    -- make sure linking order is correct
    add_links("gdcmMEXD", "gdcmMSFF", "gdcmDICT", "gdcmIOD", "gdcmDSED", "gdcmCommon", "gdcmuuid", "gdcmjpeg8", "gdcmjpeg12", "gdcmjpeg16", "socketxx")

    on_load(function (package) 
        package:add("includedirs", "include/gdcm-" .. package:version():major() .. "." .. package:version():minor())
        for config, _ in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", config)
            end
        end
    end)

    on_install("windows|!arm64", "linux", "macosx", "bsd", function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DGDCM_BUILD_TESTING=OFF",
            "-DGDCM_BUILD_DOCBOOK_MANPAGES=OFF",
            "-DGDCM_USE_SYSTEM_CHARLS=ON",
            "-DGDCM_USE_SYSTEM_EXPAT=ON",
            "-DGDCM_USE_SYSTEM_OPENJPEG=ON",
            "-DGDCM_USE_SYSTEM_ZLIB=ON",
        }
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DGDCM_USE_SYSTEM_" .. dep .. "=" .. (package:config(config) and "ON" or "OFF"))
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <gdcmReader.h>
            #include <gdcmWriter.h>
            #include <gdcmDataSet.h>
            #include <gdcmUIDGenerator.h>
            void test() {
                gdcm::Reader reader;
                gdcm::Writer writer;
                gdcm::DataSet ds;
                gdcm::UIDGenerator uid;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)