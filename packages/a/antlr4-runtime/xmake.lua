package("antlr4-runtime")
    set_homepage("http://antlr.org")
    set_description("ANTLR (ANother Tool for Language Recognition) is a powerful parser generator for reading, processing, executing, or translating structured text or binary files.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/antlr/antlr4/archive/refs/tags/$(version).tar.gz",
             "https://github.com/antlr/antlr4.git")

    add_versions("4.13.1", "da20d487524d7f0a8b13f73a8dc326de7fc2e5775f5a49693c0a4e59c6b1410c")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DANTLR_BUILD_CPP_TESTS=OFF", "-DANTLR4_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DANTLR_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DANTLR_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))

        os.cd("runtime/Cpp")
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")]], "", {plain = true})
        import("package.tools.cmake").install(package, configs)
        if not package:config("shared") then
            package:add("defines", "ANTLR4CPP_STATIC")
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("antlr4::ANTLRInputStream", {configs = {languages = "c++17"}, includes = "antlr4-runtime/antlr4-runtime.h"}))
    end)
