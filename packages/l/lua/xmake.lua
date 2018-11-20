package("lua")

    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    set_urls("https://www.lua.org/ftp/lua-$(version).tar.gz",
             "https://github.com/lua/lua.git")

    add_versions("5.3.5", "0c2eed3f960446e1a3e4b9a1ca2f3ff893b6ce41942cf54d5dd59ab4b3b058ac")

    on_install("macosx", "linux", function (package)
        io.gsub("./Makefile", "INSTALL_TOP= /usr/local", "INSTALL_TOP=" .. package:installdir())
        if is_plat("macosx") then
            os.vrun("make macosx")
        else
            os.vrun("make linux")
        end
        os.vrun("make install")
    end)

