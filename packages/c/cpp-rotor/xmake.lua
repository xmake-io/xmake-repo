package("cpp-rotor")
    set_homepage("https://github.com/basiliscos/cpp-rotor")
    set_description("Event loop friendly C++ actor micro-framework, supervisable")
    set_license("MIT")

    add_urls("https://github.com/basiliscos/cpp-rotor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/basiliscos/cpp-rotor.git", {submodules = false})

    add_versions("v0.37", "d432013285ef4969c56269e32854818c0cd94a984ef8c6795a29fb48a8067c71")
    add_versions("v0.36", "9dce406c2a72baf804af5161f87fd5822433566de348cb7eb48789a4db4c05d1")
    add_versions("v0.35", "245fdda4374ed7a0af18b682b1d861df87d05162daeca263776259a31d1dd4b9")
    add_versions("v0.34", "8c59a36b3b2917c91650fb91e57f8e116e0dd7f88b70d95e2e92bde4f9395202")
    add_versions("v0.33", "0a57af1018e2ca89c9cd95ae134c4b2af2c8e803c81ebee5433495776830eea6")
    add_versions("v0.32", "b0b7a294704f1ab779b95ab433eb5f4a2859db3539108a0e08709fc97f6bccee")
    add_versions("v0.31", "c8d9b28083c7a9c32af2cbff1d90fe1e62def989f0f89baba1244c44fb8ec9e4")
    add_versions("v0.30", "d143bfce1d18d42ab0f072acfe239d1cc07a495411537579e02260673cbe8121")

    add_configs("boost_asio", {description = "Build with boost:asio", default = false, type = "boolean"})
    add_configs("libev", {description = "Build with libev", default = false, type = "boolean"})
    add_configs("fltk", {description = "Build with fltk", default = false, type = "boolean"})
    add_configs("thread", {description = "Build with thread", default = false, type = "boolean"})
    add_configs("multithreading", {description = "Build with multithreading", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {date_time = true, regex = true, system = true}})

    on_load(function (package)
        if package:config("boost_asio") or package:config("thread") then
            if package:is_plat("linux", "bsd") then
                package:add("syslinks", "pthread")
            end
        end
        if package:config("libev") then
            package:add("deps", "libev")
        end
        if package:config("fltk") then
            package:add("deps", "fltk")
        end

        if package:config("multithreading") then
            package:add("defines", "ROTOR_REFCOUNT_THREADUNSAFE")
        end
        if not package:config("shared") then
            package:add("defines", "ROTOR_STATIC_DEFINE")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "cross", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DROTOR_DEBUG_DELIVERY=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end

        table.insert(configs, "-DBUILD_BOOST_ASIO=" .. (package:config("boost_asio") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_EV=" .. (package:config("libev") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_FLTK=" .. (package:config("fltk") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_THREAD=" .. (package:config("thread") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_THREAD_UNSAFE=" .. (package:config("multithreading") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                rotor::system_context_t ctx{};
            }
        ]]}, {configs = {languages = "c++17"}, includes = "rotor.hpp"}))
    end)
