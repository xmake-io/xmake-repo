package("doxygen")

    set_kind("binary")
    set_homepage("https://www.doxygen.nl/")
    set_license("GPL-2.0")

    if is_host("windows") then
        if is_arch("x86") then
            add_urls("https://doxygen.nl/files/doxygen-$(version).windows.bin.zip")
            add_versions("1.9.1", "c9782f545be757dac6e424f5347b7bbf1169da927058dc9954d801a5e8399de5")
        elseif is_arch("x64") then
            add_urls("https://doxygen.nl/files/doxygen-$(version).windows.x64.bin.zip")
            add_versions("1.9.1", "deb8e6e5f21c965ec07fd32589d0332eff047f2c8658b5c56be4839a5dd43353")
        end
    else
        add_urls("https://doxygen.nl/files/doxygen-$(version).src.tar.gz")
        add_versions("1.9.1", "67aeae1be4e1565519898f46f1f7092f1973cce8a767e93101ee0111717091d1")

        add_deps("cmake", "python 3.x", "bison", "flex", {kind = "binary"})
    end

    on_install("@windows", function (package)
        os.mv("*.exe", package:installdir("bin"))
        os.mv("*.dll", package:installdir("bin"))
    end)

    on_install("@macosx", "@linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        os.vrun("doxygen -v")
    end)
