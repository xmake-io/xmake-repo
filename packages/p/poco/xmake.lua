package("poco")

    set_homepage("https://pocoproject.org/")
    set_description("The POCO C++ Libraries are powerful cross-platform C++ libraries for building network- and internet-based applications that run on desktop, server, mobile, IoT, and embedded systems.")
    set_license("BSL-1.0")

    add_urls("https://github.com/pocoproject/poco/archive/refs/tags/poco-$(version)-release.tar.gz",
             "https://github.com/pocoproject/poco.git")
    add_versions("1.10.1", "44592a488d2830c0b4f3bfe4ae41f0c46abbfad49828d938714444e858a00818")

    add_deps("cmake", "zlib")
    if is_plat("windows") then
        add_deps("pcre", "expat", {configs = {shared = true}})
    else
        add_deps("pcre", "expat")
    end
    add_deps("openssl", "sqlite3", {optional = true})
    add_deps("postgresql", {system = true, optional = true})
    on_install("windows", "linux", "macosx", function (package)
        io.gsub("CMakeLists.txt", "install%(FILES.-%)", "")
        local configs = {"-DPOCO_UNBUNDLED=ON", "-DENABLE_PDF=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DPOCO_MT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        else
            -- shared library is not supported on windows
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Poco::BasicEvent<int>", {configs = {languages = "c++11"}, includes = "Poco/BasicEvent.h"}))
    end)
