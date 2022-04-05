package("libharu")

    set_homepage("http://libharu.org/")
    set_description("libHaru is a free, cross platform, open source library for generating PDF files.")
    set_license("zlib")

    add_urls("https://github.com/libharu/libharu/archive/refs/tags/RELEASE_$(version).tar.gz", {version = function (version) return version:gsub("%.", "_") end})
    add_urls("https://github.com/libharu/libharu.git")
    add_versions("2.3.0", "8f9e68cc5d5f7d53d1bc61a1ed876add1faf4f91070dbc360d8b259f46d9a4d2")

    add_deps("cmake", "zlib", "libpng")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "HPDF_DLL")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("src/CMakeLists.txt", "install(FILES ${addlib}", "#", {plain = true})
        local configs = {"-DLIBHPDF_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBHPDF_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBHPDF_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("HPDF_GetVersion", {includes = "hpdf.h"}))
    end)
