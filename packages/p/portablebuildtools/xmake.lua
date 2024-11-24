package("portablebuildtools")
    set_kind("toolchain")
    set_homepage("https://github.com/Data-Oriented-House/PortableBuildTools")
    set_description("Portable VS Build Tools installer")

    add_urls("https://github.com/Data-Oriented-House/PortableBuildTools/releases/download/$(version)/PortableBuildTools.exe")

    add_versions("v2.8", "d3a419be62856ab8896004f91af58f5928ce7c536954398d02a8b99202c4808f")

    on_install("@windows", "@msys", function (package)
        os.cp(package:originfile(), package:installdir("bin"))
    end)

    on_test(function (package)
        os.runv("PortableBuildTools.exe", {"list"})
    end)

