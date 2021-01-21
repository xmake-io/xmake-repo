package("sqlite3")

    set_homepage("https://sqlite.org/")
    set_description("The most used database engine in the world")

    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local year = "2021"
        if version:le("3.24") then
            year = "2018"
        end
        local version_str = version:gsub("[.+]", "")
        if #version_str < 7 then
            version_str = version_str .. "00"
        end
        return year .. "/sqlite-autoconf-" .. version_str .. ".tar.gz"
    end})

    add_versions("3.23.0+0",   "b7711a1800a071674c2bf76898ae8584fc6c9643cfe933cfc1bc54361e3a6e49")
    add_versions("3.24.0+0",   "d9d14e88c6fb6d68de9ca0d1f9797477d82fc3aed613558f87ffbdbbc5ceb74a")
    add_versions("3.34.0+100", "2a3bca581117b3b88e5361d0ef3803ba6d8da604b1c1a47d902ef785c1b53e89")

    on_install("windows", function (package)
        local configs = {"-f", "Makefile.msc", "DYNAMIC_SHELL=1"}
        table.insert(configs, "DEBUG=" .. (package:debug() and "1" or "0"))
        table.insert(configs, "PLATFORM=" .. package:arch())
        table.insert(configs, "USE_CRT_DLL=" .. (package:config("vs_runtime"):startswith("MD") and "1" or "0"))
        import("package.tools.nmake").build(package, configs)
        os.cp("*.h", package:installdir("include"))
        os.cp("sqlite3.lib", package:installdir("lib"))
        os.cp("sqlite3.pdb", package:installdir("bin"))
        os.cp("sqlite3.dll", package:installdir("bin"))
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {package:debug() and "--enable-debug" or ""})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_open_v2", {includes = "sqlite3.h"}))
    end)
