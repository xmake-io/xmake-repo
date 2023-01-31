package("lzma")

    set_homepage("https://www.7-zip.org/sdk.html")
    set_description("LZMA SDK")

    add_urls("https://www.7-zip.org/a/lzma$(version).7z", {version = function (version) return version:gsub("%.", "") end})
    add_versions("19.00", "00f569e624b3d9ed89cf8d40136662c4c5207eaceb92a70b1044c77f84234bad")
    add_versions("22.01", "35b1689169efbc7c3c147387e5495130f371b4bad8ec24f049d28e126d52d9fe")

    on_install("windows", "linux", "macosx", function (package)
        os.cd("C")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lzma")
                set_kind("$(kind)")
                add_files("Alloc.c", "LzFind.c",  "Lzma2Dec.c", "Lzma2Enc.c", "LzmaDec.c", "LzmaEnc.c", "LzmaLib.c", "CpuArch.c")
                add_headerfiles("7zTypes.h", "LzFind.h", "LzHash.h", "Lzma2Dec.h", "Lzma2Enc.h", "LzmaDec.h", "LzmaEnc.h", "LzmaLib.h")
                if is_plat("windows") then
                    add_files("LzFindMt.c", "LzFindOpt.c", "MtCoder.c", "MtDec.c", "Threads.c", "DllSecur.c", "Lzma2DecMt.c")
                    add_headerfiles("LzFindMt.h", "Lzma2DecMt.h")
                else
                    add_defines("_7ZIP_ST")
                end
        ]])
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LzmaCompress", {includes = "LzmaLib.h"}))
    end)
