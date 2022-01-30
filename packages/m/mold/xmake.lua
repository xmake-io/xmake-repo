package("mold")
    set_kind("binary")
    set_homepage("https://github.com/rui314/mold")
    set_description("mold: A Modern Linker")

    add_urls("https://github.com/rui314/mold.git")
    add_versions("1.0.1", "fe209f3f4c7177b0613f8c10f38862a23d8fb8f0")

    add_deps("cmake", "pkg-config", "zlib")
    if is_plat("linux") then
        add_deps("openssl")
    end

    on_install("linux", "macosx", function (package)
        local configs = {}
        local cflags = {}
        local ldflags = {}
        for _, name in ipairs({"zlib", "openssl"}) do
            local dep = package:dep(name)
            if dep then
                local depinfo = dep:fetch()
                if depinfo then
                    for _, includedir in ipairs(depinfo.includedirs or depinfo.sysincludedirs) do
                        table.insert(cflags, "-I" .. includedir)
                    end
                    for _, linkdir in ipairs(depinfo.linkdirs) do
                        table.insert(ldflags, "-L" .. linkdir)
                    end
                end
            end
        end
        if #cflags > 0 then
            table.insert(configs, "EXTRA_CFLAGS=" .. table.concat(cflags, " "))
            table.insert(configs, "EXTRA_CXXFLAGS=" .. table.concat(cflags, " "))
        end
        if #ldflags > 0 then
            table.insert(configs, "EXTRA_LDFLAGS=" .. table.concat(ldflags, " "))
        end
        table.insert(configs, "mold")
        import("package.tools.make").make(package, configs)
        os.cp("mold", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("mold --version")
    end)
