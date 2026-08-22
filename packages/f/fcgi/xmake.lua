package("fcgi")
    set_homepage("https://fastcgi-archives.github.io")
    set_description("Protocol for interfacing interactive programs with a web server")
    set_license("OML")

    set_urls("https://github.com/FastCGI-Archives/fcgi2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/FastCGI-Archives/fcgi2.git")

    add_versions("2.4.7", "e41ddc3a473b555bdc0cbd80703dcb1f4610c1a7700d3b9d3d0c14a416e1074b")
    add_versions("2.4.6", "39af4fb21a6d695a5f0b1c4fa95776d2725f6bc6c77680943a2ab314acd505c1")

    if is_plat("windows", "mingw") and is_arch("x64", "x86_64") then
        add_patches("*", "patches/windows_type.patch", "921143191bc0f2c33773d35a7a0352ab04c95963e03073c3f9dc3ec5c7751340")
    end

    add_links("fcgi++", "fcgi")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_install(function (package)
        if package:is_plat("windows") and  not package:config("shared") then
            package:add("defines", "DLLAPI=")
        end
        os.cp(path.join(package:scriptdir(), "port", "fcgi_config.h.in"), "fcgi_config.h.in")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {ver = package:version_str()})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FCGI_Accept", {includes = "fcgi_stdio.h"}))
    end)
