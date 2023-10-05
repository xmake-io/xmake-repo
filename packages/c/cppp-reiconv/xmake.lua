package("cppp-reiconv")
    add_deps("cmake", "python")
    set_homepage("https://github.com/cppp-project/cppp-reiconv")
    set_description("A character set conversion library based on GNU LIBICONV.")

    add_urls("https://github.com/cppp-project/cppp-reiconv/releases/download/$(version)/cppp-reiconv-$(version).zip")

    add_versions("v2.1.0", "3e539785a437843793c5ce2f8a72cb08f2b543cba11635b06db25cfc6d9cc3a4")

    add_deps("cmake")
    
    on_download(function (package, opt)
        import("net.http")
        import("utils.archive")

        local url = opt.url
        local sourcedir = opt.sourcedir
        local packagefile = path.filename(url)
        local sourcehash = package:sourcehash(opt.url_alias)

        local cached = true
        if not os.isfile(packagefile) or sourcehash ~= hash.sha256(packagefile) then
            cached = false

            os.tryrm(packagefile)
            http.download(url, packagefile)

            if sourcehash and sourcehash ~= hash.sha256(packagefile) then
                raise("unmatched checksum, current hash(%s) != original hash(%s)", hash.sha256(packagefile):sub(1, 8), sourcehash:sub(1, 8))
            end
        end

        local sourcedir_tmp = sourcedir .. ".tmp"
        os.rm(sourcedir_tmp)
        if archive.extract(packagefile, sourcedir_tmp) then
            os.rm(sourcedir)
            os.mv(sourcedir_tmp, sourcedir)
        else
            os.tryrm(sourcedir)
            os.mkdir(sourcedir)
        end
        package:originfile_set(path.absolute(packagefile))
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_EXTRA=ON")
        table.insert(configs, "-DENABLE_TEST=OFF")
        import("package.tools.cmake").install(package, configs)
    end)
