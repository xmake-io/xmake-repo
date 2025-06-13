package("libharu")
    set_homepage("http://libharu.org/")
    set_description("libHaru is a free, cross platform, open source library for generating PDF files.")
    set_license("zlib")

    add_urls("https://github.com/libharu/libharu/archive/refs/tags/$(version).tar.gz", {version = function (version)
        if version:lt("2.4.0") then
            return "RELEASE_" .. version:gsub("%.", "_")
        else
            return version
        end
    end})
    add_urls("https://github.com/libharu/libharu.git")

    add_versions("v2.4.5", "0ed3eacf3ceee18e40b6adffbc433f1afbe3c93500291cd95f1477bffe6f24fc")
    add_versions("2.3.0", "8f9e68cc5d5f7d53d1bc61a1ed876add1faf4f91070dbc360d8b259f46d9a4d2")

    add_deps("cmake")
    add_deps("zlib", "libpng")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load("windows", function (package)
        if package:config("shared") then
            if package:check_sizeof("void*") == "4" then
                package:add("defines", "HPDF_DLL_CDECL")
            else
                package:add("defines", "HPDF_DLL")
            end
        end
    end)

    on_install(function (package)
        io.replace("src/CMakeLists.txt", "install(FILES ${addlib}", "#", {plain = true})
        if is_plat("cross", "wasm") then
            io.replace("cmake/modules/haru.cmake", [[message(FATAL_ERROR "Cannot find required math library")]], [[set(MATH_LIB)]], {plain = true})
        end
        local configs = {"-DLIBHPDF_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBHPDF_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBHPDF_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("HPDF_GetVersion", {includes = "hpdf.h"}))
    end)
