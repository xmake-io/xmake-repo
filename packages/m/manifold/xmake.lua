package("manifold")

    set_homepage("https://github.com/elalish/manifold")
    set_description("A Geometry library for topological robustness")

    set_urls("https://github.com/elalish/manifold/releases/download/v$(version)/manifold-$(version).tar.gz")

    add_versions("3.2.1","67c4e0cb836f9d6dfcb7169e9d19a7bb922c4d4bfa1a9de9ecbc5d414018d6ad")
    
    add_configs("jsbind", {description = "Enable js binding", default = false, type = "boolean"})
    add_configs("cbind", {description = "Enable c binding", default = true, type = "boolean"})
    add_configs("pybind", {description = "Enable python binding", default = false, type = "boolean"})
    
    add_configs("parellel", {description = "Enable parellel processing", default = true, type = "boolean"}) --不开启的话你为什么不去用libigl呢 ：)
    add_configs("clipper2_feature", {description = "Enable 2d simple operation", default = true, type = "boolean"})
    add_configs("exporter", {description = "Enable exporting models", default = true, type = "boolean"})
    
    add_configs("debug", {description = "Enable debug", default = false, type = "boolean"})
    add_configs("assert", {description = "Enable debug assert", default = false, type = "boolean"}) --只能和DEBUG一起开！！
    
    add_configs("test", {description = "Enable test", default = false, type = "boolean"})
    add_configs("tracy", {description = "Enable profiling", default = false, type = "boolean"})
    
    add_deps("cmake") --necessary for cmake project
    
        
    on_install("windows", function (package)
         local configs = {}

        local cmake_args = table.join({" -DCMAKE_INSTALL_PREFIX=" .. package:installdir()},package:config("cmake_args"))
        local cachedir = package:cachedir()
        table.insert(configs,cmake_args)
        table.insert(configs,"-DMANIFOLD_DEBUG=OFF") --官方建议的我也不知道为什么一定要关闭
        
        table.insert(configs,"-DMANIFOLD_JSBIND" .. (package:config("jsbind") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_CBIND" .. (package:config("cbind") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_PYBIND" .. (package:config("pybind") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_PAR" .. (package:config("parellel") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_CROSS_SECTION" .. (package:config("clipper2_feature") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_EXPORT" .. (package:config("exporter") and "ON" or "OFF"))

        table.insert(configs,"-DMANIFOLD_ASSERT" .. (package:config("assert") and "ON" or "OFF"))
        
        table.insert(configs,"-DMANIFOLD_TEST" .. (package:config("test") and "ON" or "OFF"))
        table.insert(configs,"-DTRACY_ENABLE" .. (package:config("tracy") and "ON" or "OFF"))
        
        table.insert(configs,"-DMANIFOLD_USE_BUILTIN_TBB=ON")
        table.insert(configs,"-DMANIFOLD_USE_BUILTIN_CLIPPER2=ON")  --clipper2需要依赖他的版本 :( 不然不方便
        table.insert(configs,"-DMANIFOLD_USE_BUILTIN_NANOBIND=ON") 
        import("package.tools.cmake").install(package, configs)
    end)


    on_install("linux", "macosx", function (package)
        local configs = {}

        local cmake_args = table.join({" -DCMAKE_INSTALL_PREFIX=" .. package:installdir()},package:config("cmake_args"))

        table.insert(configs,"-DMANIFOLD_JSBIND" .. (package:config("jsbind") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_CBIND" .. (package:config("cbind") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_PYBIND" .. (package:config("pybind") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_PAR" .. (package:config("parellel") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_CROSS_SECTION" .. (package:config("clipper2_feature") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_EXPORT" .. (package:config("exporter") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_DEBUG" .. (package:config("debug") and "ON" or "OFF"))
        table.insert(configs,"-DMANIFOLD_ASSERT" .. (package:config("assert") and "ON" or "OFF"))

        table.insert(configs,"-DMANIFOLD_TEST" .. (package:config("test") and "ON" or "OFF"))
        table.insert(configs,"-DTRACY_ENABLE" .. (package:config("tracy") and "ON" or "OFF"))
        
        
        
        table.insert(configs,cmake_args)
        table.insert(configs,"-DMANIFOLD_USE_BUILTIN_TBB=ON")
        table.insert(configs,"-DMANIFOLD_USE_BUILTIN_CLIPPER2=ON")
        table.insert(configs,"-DMANIFOLD_USE_BUILTIN_NANOBIND=ON")
        import("package.tools.cmake").install(package, configs)


    end)

    on_test(function (package)
        import("lib.detect.find_file")
        local file = find_file("libmanifold.a", {package:installdir()})
        assert(file == nil)
    end)
