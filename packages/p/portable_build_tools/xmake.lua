package("portable_build_tools")
    set_kind("toolchain")
    set_homepage("https://github.com/Data-Oriented-House/PortableBuildTools")
    set_description("Portable VS Build Tools installer")

    add_urls("https://github.com/Data-Oriented-House/PortableBuildTools/releases/download/$(version)/PortableBuildTools.exe")

    add_versions("v2.9.2", "d2e432cba14ec405460b0a7d3950d16df9d1cc9e64b48c03fa6e324c96b1105b")
    add_versions("v2.8.1", "5663660d0e61cdc7e57a74a8dfc30337895a1cd56d345fe62556bcdb6b896d84")
    add_versions("v2.8", "d3a419be62856ab8896004f91af58f5928ce7c536954398d02a8b99202c4808f")

    on_install("@windows", "@msys", function (package)
        os.cp(package:originfile(), package:installdir("bin"))
    end)

    on_test(function (package)
        os.runv("PortableBuildTools.exe", {"list"})
    end)

