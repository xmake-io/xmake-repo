package("poppler")

    set_homepage("https://poppler.freedesktop.org/")
    set_description("Poppler, a PDF rendering library")
    set_license("GPL-2.0")

    add_urls("https://poppler.freedesktop.org/poppler-$(version).tar.xz")
    add_versions("21.03.0", "fd51ead4aac1d2f4684fa6e7b0ec06f0233ed21667e720a4e817e4455dd63d27")

    local libnames = {"splash", "glib", "qt5", "qt6"}
    for _, libname in ipairs(libnames) do
        add_configs(libname, {description = "Enable " .. libname .. " for use.", default = (libname == "splash"), type = "boolean"})
    end

    add_deps("cmake")
    add_deps("libtiff", "openjpeg", "lcms", "libjpeg", "libpng", "bzip2", "zlib")
    if is_plat("linux") then
        add_deps("fontconfig", "expat")
    else
        add_deps("freetype", {configs = {woff2 = false, png = false, bzip2 = false}})
    end

    add_includedirs("include")
    add_includedirs("include/poppler")

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "if(MSVC)\n", "if(MSVC)\nadd_definitions(-D_BASETSD_H)\n", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        io.replace("CMakeLists.txt", "set(ENABLE_LIBPNG ON)\n", "set(ENABLE_LIBPNG ON)\ninclude_directories(SYSTEM ${PNG_INCLUDE_DIRS})\n", {plain = true})
        local configs = {"-DENABLE_UNSTABLE_API_ABI_HEADERS=ON", "-DBUILD_GTK_TESTS=OFF", "-DBUILD_QT5_TESTS=OFF", "-DBUILD_QT6_TESTS=OFF", "-DBUILD_CPP_TESTS=OFF", "-DENABLE_CPP=OFF", "-DENABLE_UTILS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for _, libname in ipairs(libnames) do
            table.insert(configs, "-DENABLE_" .. libname:upper() .. "=" .. (package:config(libname) and "ON" or "OFF"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("PDFDocBuilder", {configs = {languages = "c++11"}, includes = "PDFDocBuilder.h"}))
    end)
