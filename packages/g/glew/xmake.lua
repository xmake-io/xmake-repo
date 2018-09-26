package("glew")

    set_homepage("http://glew.sourceforge.net/")
    set_description("A cross-platform open-source C/C++ extension loading library.")

    if is_plat("windows") then
        set_urls("https://github.com/nigels-com/glew/releases/download/glew-$(version)/glew-$(version)-win32.zip")
        add_versions("2.1.0", "80cfc88fd295426b49001a9dc521da793f8547ac10aebfc8bdc91ddc06c5566c")
    else
        set_urls("https://github.com/nigels-com/glew/releases/download/glew-$(version)/glew-$(version).zip")
        add_versions("2.1.0", "2700383d4de2455f06114fbaf872684f15529d4bdc5cdea69b5fb0e9aa7763f1")
    end

    on_build("windows", function (package)
    end)

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        if is_arch("x64") then
            os.cp("bin/Release/x64/*.dll", package:installdir("lib"))
            os.cp("lib/Release/x64/*.lib", package:installdir("lib"))
        else
            os.cp("bin/Release/Win32/*.dll", package:installdir("lib"))
            os.cp("lib/Release/Win32/*.lib", package:installdir("lib"))
        end
        package:addvar("links", "glew32s")
    end)

    on_build("linux", "macosx", function (package)
        os.vrun("make")
    end)

    on_install("linux", "macosx", function (package)
        os.cp("lib", package:installdir())
        os.cp("include", package:installdir())
    end)
