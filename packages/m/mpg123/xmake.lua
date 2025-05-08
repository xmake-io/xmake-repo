package("mpg123")
    set_homepage("https://www.mpg123.de/")
    set_description("Fast console MPEG Audio Player and decoder library")

    add_urls("https://sourceforge.net/projects/mpg123/files/mpg123/$(version)/mpg123-$(version).tar.bz2")

    add_versions("1.32.10", "87b2c17fe0c979d3ef38eeceff6362b35b28ac8589fbf1854b5be75c9ab6557c")
    add_versions("1.30.2", "c7ea863756bb79daed7cba2942ad3b267a410f26d2dfbd9aaf84451ff28a05d7")

    if not is_subhost("windows") then
        add_deps("autoconf", "automake", "libtool")
    end
    
    if is_plat("linux") then
        add_syslinks("m")
    end

    on_load(function(package)
        if is_subhost("windows") then
            local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
            package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true, gcc = true, make = true}})
        end
    end)

    on_install("linux", "macosx", "android", "iphoneos", "bsd", "cross", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if is_subhost("windows") then
            import("core.base.option")
            import("package.tools.autoconf")
            autoconf.configure(package, configs)
            local njob = option.get("jobs") or tostring(os.default_njob())
            local argv = {"-j" .. njob}
            if option.get("verbose") then
                table.insert(argv, "V=1")
            end
            -- using execv instead of vrunv is needed when compiling on windows, otherwise it fail with
            -- ../libtool: line 3331: 0: Bad file descriptor
            -- when -v is not supplied to xmake
            os.vrunv("make", argv, {shell = true})
            os.vrunv("make", table.join({"install"}, argv), {shell = true})
        else
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpg123_init", {includes = "mpg123.h"}))
    end)
