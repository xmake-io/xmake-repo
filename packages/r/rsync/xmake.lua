package("rsync")

    set_kind("binary")
    set_homepage("https://rsync.samba.org/")
    set_description("rsync is an open source utility that provides fast incremental file transfer.")
    set_license("GPL-3.0")

    add_urls("https://download.samba.org/pub/rsync/src/rsync-$(version).tar.gz")
    add_versions("3.4.1", "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52")
    add_versions("3.2.3", "becc3c504ceea499f4167a260040ccf4d9f2ef9499ad5683c179a697146ce50e")

    add_deps("openssl", "xxhash", "lz4", "acl", "zstd", {host = true})

    on_install("linux", function (package)
        local cxflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cxflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags, ldflags = ldflags})
    end)

    on_test(function (package)
        os.vrun("rsync --version")
    end)
