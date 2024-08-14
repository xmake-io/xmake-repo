package("ynbt")
    set_description("YNBT is a cross platform NBT ser/de library for C++23")
    set_license("MIT")
    add_deps("abseil")
    add_deps("zlib")

    add_urls("https://github.com/Ymir-Editor/YNBT.git")
    add_versions("1.0", "9bb4b59214607ff9bd269c6e3885c067fe1369bd")
    add_versions("1.2", "25731f642952a06ce77b69d74803668267646091")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
    end)
