package("ynbt")
    set_description("YNBT is a cross platform NBT ser/de library for C++23")
    set_license("MIT")
    add_urls("https://github.com/Ymir-Editor/YNBT.git")

    add_versions("1.3", "7184803d593a0399884f0d12644f760c5ccbdf17")
    add_versions("1.3.1", "b3262bba1034d5be2343a611119f442233135a29")

    add_deps("abseil", "zlib")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)
   
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
           void test() {
              auto tag = YNBT::TagFromId(0);
              (void)tag.index();
           }
        ]]}, {includes = "ynbt/ynbt.hpp", configs = {languages = "cxx23"}}))
    end)

    
