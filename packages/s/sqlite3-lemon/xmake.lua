package("sqlite3-lemon")

    set_kind("binary")
    set_homepage("https://sqlite.org/")
    set_description("A parser generator")
    set_license("Public Domain")

    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local year = "2025"
        if version:le("3.24") then
            year = "2018"
        elseif version:le("3.36") then
            year = "2021"
        elseif version:le("3.42") then
            year = "2022"
        elseif version:le("3.44") then
            year = "2023"
        elseif version:lt("3.48") then
            year = "2024"
        end
        local version_str = version:gsub("[.+]", "")
        if #version_str < 7 then
            version_str = version_str .. "00"
        end
        return year .. "/sqlite-src-" .. version_str .. ".zip"
    end})

    add_versions("3.49.0+200", "c3101978244669a43bc09f44fa21e47a4e25cdf440f1829e9eff176b9a477862")

    if is_plat("macosx", "linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_install(function (package) 
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_encodings("utf-8")

            target("lemon")
                set_kind("binary")
                add_files("tool/lemon.c")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("lemon -x")
    end)
