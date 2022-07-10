package("DataFrame")

    set_homepage("https://github.com/hosseinmoein/DataFrame")
    set_description("This is a C++ analytical library that provides interface and functionality similar to packages/libraries in Python and R.")
    set_license("MIT")
    add_urls("https://github.com/hosseinmoein/DataFrame/archive/refs/tags/$(version).zip",
             "https://github.com/hosseinmoein/DataFrame.git")

    add_versions("v1.20.0", "efe74cd0af9e71bf139327c2b8b7a6917c6a2ed3")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

