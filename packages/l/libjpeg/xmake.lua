package("libjpeg")

    set_homepage("http://ijg.org/")
    set_description("A widely used C library for reading and writing JPEG image files.")

    set_urls("https://www.ijg.org/files/jpegsrc.$(version).tar.gz")
    add_versions("v9b", "566241ad815df935390b341a5d3d15a73a4000e5aab40c58505324c2855cbbb8")
    add_versions("v9c", "682aee469c3ca857c4c38c37a6edadbfca4b04d42e56613b11590ec6aa4a278d")
    add_versions("v9d", "2303a6acfb6cc533e0e86e8a9d29f7e6079e118b9de3f96e07a71a11c082fa6a")
    add_versions("v9e", "4077d6a6a75aeb01884f708919d25934c93305e49f7e3f36db9129320e6f4f3d")

    add_configs("headeronly", {description = "Install headerfiles only.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libjpeg-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::jpeg/libjpeg")
    end

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")

            target("jpeg")
                set_kind("static")

                add_files("jaricom.c", "jcapimin.c", "jcapistd.c", "jcarith.c", "jccoefct.c", "jccolor.c")
                add_files("jcdctmgr.c", "jchuff.c", "jcinit.c", "jcmainct.c", "jcmarker.c", "jcmaster.c")
                add_files("jcomapi.c", "jcparam.c", "jcprepct.c", "jcsample.c", "jctrans.c", "jdapimin.c")
                add_files("jdapistd.c", "jdarith.c", "jdatadst.c", "jdatasrc.c", "jdcoefct.c", "jdcolor.c")
                add_files("jddctmgr.c", "jdhuff.c", "jdinput.c", "jdmainct.c", "jdmarker.c", "jdmaster.c")
                add_files("jdmerge.c", "jdpostct.c", "jdsample.c", "jdtrans.c", "jerror.c", "jfdctflt.c")
                add_files("jfdctfst.c", "jfdctint.c", "jidctflt.c", "jidctfst.c", "jidctint.c", "jquant1.c")
                add_files("jquant2.c", "jutils.c", "jmemmgr.c", "jmemansi.c")

                if is_plat("windows") then
                    add_configfiles("jconfig.vc", {filename = "jconfig.h"})
                else
                    add_configfiles("jconfig.txt", {filename = "jconfig.h"})
                end
                add_includedirs("$(buildir)", {public = true})
                add_headerfiles("jerror.h", "jmorecfg.h", "jpeglib.h", "$(buildir)/jconfig.h")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        if package:config("headeronly") then
            if package:is_plat("windows") then
                os.cp("jconfig.vc", "jconfig.h")
            else
                os.cp("jconfig.txt", "jconfig.h")
            end
            os.cp("*.h", package:installdir("include"))
        else
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        if package:config("headeronly") then
            assert(package:has_cincludes({"stdio.h", "jpeglib.h"}))
        else
            assert(package:has_cfuncs("jpeg_create_compress(0)", {includes = {"stdio.h", "jpeglib.h"}}))
        end
    end)
