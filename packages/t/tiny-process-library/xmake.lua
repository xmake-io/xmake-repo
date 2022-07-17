package("tiny-process-library")
    set_homepage("https://github.com/eidheim/tiny-process-library")
    set_description("A small platform independent library making it simple to create and stop new processes in C++, as well as writing to stdin and reading from stdout and stderr of a new process")
    set_license("MIT")

    add_urls("https://gitlab.com/eidheim/tiny-process-library/-/archive/$(version)/tiny-process-library-$(version).tar.gz",
             "https://gitlab.com/eidheim/tiny-process-library.git")
    add_versions("v2.0.4", "b99dcb51461323b8284a7762ad105c159b88cdcce0c2cc183e4f474f80ef1f1a")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("TinyProcessLib::Process", {configs = {languages = "c++11"}, includes = "process.hpp"}))
    end)
