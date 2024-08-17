package("ynbt")
    set_description("YNBT is a cross platform NBT ser/de library for C++23")
    set_license("MIT")
    add_urls("https://github.com/Ymir-Editor/YNBT.git")

    add_versions("1.3", "7184803d593a0399884f0d12644f760c5ccbdf17")

    add_deps("abseil")
    add_deps("zlib")
    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)
   
    on_test(function (package)
        assert(package:has_cxxtypes("YNBT::NBTFile", {includes = "ynbt/ynbt.hpp", configs = {languages="cxx23"}}))
    end)

    
