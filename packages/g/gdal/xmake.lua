package("gdal")
    set_homepage("https://gdal.org/")
    set_description("GDAL is a translator library for raster and vector geospatial data formats by the Open Source Geospatial Foundation")
    set_license("MIT")

    add_urls("https://github.com/OSGeo/gdal/releases/download/v$(version)/gdal-$(version).tar.gz")
    add_versions("3.12.1", "266cbadf8534d1de831db8834374afd95603e0a6af4f53d0547ae0d46bd3d2d1")
    add_versions("3.11.3", "54638f6990f84c16142d93c9daaafaf1eab0a6a61538162095c334de086ef91f")
    add_versions("3.11.1", "21f1806070ccff697946ba5df5a0ec9ee9ecfcbb7e7e6163f2c61466883e23f8")
    add_versions("3.10.2", "ca710aab81eb4d638f5dbd4f03d4d4b902aeb6ee73a3d4a8c5e966b6b648b0da")
    add_versions("3.10.0", "946ef444489bedbc1b04bd4c115d67ae8d3f3e4a5798d5a2f1cb2a11014105b2")
    add_versions("3.9.3", "f293d8ccc6b98f617db88f8593eae37f7e4b32d49a615b2cba5ced12c7bebdae")
    add_versions("3.9.2", "c9767e79ca7245f704bfbcb47d771b2dc317d743536b78d648c3e92b95fbc21e")
    add_versions("3.9.1", "46cd95ad0f270af0cd317ddc28fa5e0a7ad0b0fd160a7bd22909150df53e3418")
    add_versions("3.9.0", "3b29b573b60d156cf160805290474b625c4197ca36a79fd14f83ec8f77f29ba0")
    add_versions("3.8.5", "0c865c7931c7e9bb4832f50fb53aec8676cbbaccd6e55945011b737fb89a49c2")
    add_versions("3.5.1", "7c4406ca010dc8632703a0a326f39e9db25d9f1f6ebaaeca64a963e3fac123d1")

    add_deps("cmake")
    add_configs("apps", {description = "Build GDAL applications.", default = false, type = "boolean"})
    add_configs("curl", {description = "Use CURL.", default = false, type = "boolean"})
    add_configs("geos", {description = "Use GEOS.", default = false, type = "boolean"})
    add_configs("gif", {description = "Use GIF.", default = false, type = "boolean"})
    add_configs("iconv", {description = "Use Iconv.", default = false, type = "boolean"})
    add_configs("jpeg", {description = "Use JPEG.", default = false, type = "boolean"})
    add_configs("openjpeg", {description = "Use OpenJPEG.", default = true, type = "boolean"}) -- default true to keep compatibility
    add_configs("openssl", {description = "Use OpenSSL.", default = false, type = "boolean"})
    add_configs("png", {description = "Use PNG.", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Use SQLite3.", default = false, type = "boolean"})
    add_configs("xercesc", {description = "Use Xerces-C.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("wsock32", "ws2_32")
    end

    on_load(function (package)
        package:add("deps", "proj", {configs = {curl = package:config("curl")}})

        local configdeps = {
            curl = "libcurl",
            geos = "geos",
            gif = "giflib",
            iconv = "libiconv",
            jpeg = "libjpeg-turbo",
            openjpeg = "openjpeg",
            openssl = "openssl3",
            png = "libpng",
            sqlite3 = "sqlite3",
            xercesc = "xerces-c",
        }

        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows|x86", "windows|x64", "macosx", "linux", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DGDAL_USE_EXTERNAL_LIBS=OFF",
            "-DBUILD_JAVA_BINDINGS=OFF", "-DBUILD_CSHARP_BINDINGS=OFF", "-DBUILD_PYTHON_BINDINGS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_APPS=" .. (package:config("apps") and "ON" or "OFF"))

        local packagedeps = {"proj"}
        if package:config("curl") then
            table.insert(packagedeps, "libcurl")
            table.insert(configs, "-DGDAL_USE_CURL=ON")

            if not package:dep("libcurl"):config("shared") then
                table.insert(configs, "-DCURL_USE_STATIC_LIBS=ON")
            end
        end
        if package:config("geos") then
            table.insert(packagedeps, "geos")
            table.insert(configs, "-DGDAL_USE_GEOS=ON")
        end
        if package:config("gif") then
            table.insert(packagedeps, "giflib")
            table.insert(configs, "-DGDAL_USE_GIF=ON")
        end
        if package:config("iconv") then
            table.insert(packagedeps, "libiconv")
            table.insert(configs, "-DGDAL_USE_ICONV=ON")
        end
        if package:config("jpeg") then
            table.insert(packagedeps, "libjpeg-turbo")
            table.insert(configs, "-DGDAL_USE_JPEG=ON")
        end
        if package:config("openjpeg") then
            table.insert(packagedeps, "openjpeg")
            table.insert(configs, "-DGDAL_USE_OPENJPEG=ON")
        end
        if package:config("openssl") then
            table.insert(packagedeps, "openssl3")
            table.insert(configs, "-DGDAL_USE_OPENSSL=ON")
        end
        if package:config("png") then
            table.insert(packagedeps, "libpng")
            table.insert(configs, "-DGDAL_USE_PNG=ON")
        end
        if package:config("sqlite3") then
            table.insert(packagedeps, "sqlite3")
            table.insert(configs, "-DGDAL_USE_SQLITE3=ON")
        end
        if package:config("xercesc") then
            table.insert(packagedeps, "xerces-c")
            table.insert(configs, "-DGDAL_USE_XERCESC=ON")
        end

        --fix gdal compile on msvc debug mode
        local cxflags
        if package:debug() and package:is_plat("windows") then
            cxflags = "/FS"
        end
        import("package.tools.cmake").install(package, configs,
            {cxflags = cxflags, packagedeps = packagedeps})
        if package:config("apps") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("GDALAllRegister", {configs = {languages = "c++11"}, includes = "ogrsf_frmts.h"}))
    end)
