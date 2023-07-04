package("zltoolkit")
    set_homepage("https://github.com/ZLMediaKit/ZLToolKit")
    set_description("一个基于C++11的轻量级网络框架，基于线程池技术可以实现大并发网络IO")
    set_license("MIT")

    set_urls("https://github.com/ZLMediaKit/ZLToolKit.git")

    add_versions("2023.7.4", "e4744a0a523817356f2ec995ee5a732264c31629")
    
    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
       assert(package:has_cxxincludes("Network/Buffer.h"))
    end)