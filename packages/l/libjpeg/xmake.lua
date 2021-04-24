package("libjpeg")

    set_homepage("http://ijg.org/")
    set_description("A widely used C library for reading and writing JPEG image files.")

    set_urls("https://www.ijg.org/files/jpegsrc.$(version).tar.gz")

    add_versions("v9c", "650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122")
    add_versions("v9b", "240fd398da741669bf3c90366f58452ea59041cacc741a489b99f2f6a0bad052")
    add_versions("v9d", "6c434a3be59f8f62425b2e3c077e785c9ce30ee5874ea1c270e843f273ba71ee")

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
                    add_configfiles("jconfig.txt", {filename = "jconfig.h"})
                else
                    add_configfiles("jconfig.vc", {filename = "jconfig.h"})
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
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("jpeg_create_compress(0)", {includes = {"stdio.h", "jpeglib.h"}}))
    end)
