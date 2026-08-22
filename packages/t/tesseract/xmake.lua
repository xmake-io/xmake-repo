package("tesseract")

    set_homepage("https://tesseract-ocr.github.io/")
    set_description("Tesseract Open Source OCR Engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/tesseract-ocr/tesseract/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tesseract-ocr/tesseract.git")
    add_versions("5.5.2", "6235ea0dae45ea137f59c09320406f5888383741924d98855bd2ce0d16b54f21")
    add_versions("5.5.1", "a7a3f2a7420cb6a6a94d80c24163e183cf1d2f1bed2df3bbc397c81808a57237")
    add_versions("4.1.1", "2a66ff0d8595bff8f04032165e6c936389b1e5727c3ce5a27b3e059d218db1cb")
    add_versions("4.1.3", "83dc56b544be938983f528c777e4e1d906205b0f6dc0110afc223f2cc1cec6d3")
    add_versions("5.0.1", "b5b0e561650ed67feb1e9de38d4746121d302ae4c876c95b99b8b6f9f89d5c58")
    add_versions("5.2.0", "eba4deb2f92a3f89a6623812074af8c53b772079525b3c263aa70bbf7b748b3c")
    add_versions("5.3.4", "141afc12b34a14bb691a939b4b122db0d51bd38feda7f41696822bacea7710c7")

    add_configs("training",   {description = "Build training tools.", default = false, type = "boolean"})
    add_configs("libarchive", {description = "Enable build with libarchive.", default = false, type = "boolean"})
    add_configs("libcurl",    {description = "Enable build with libcurl.", default = false, type = "boolean"})
    add_configs("opencl",     {description = "Enable experimental OpenCL support.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("leptonica")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("training") then
            package:add("deps", "icu4c")
        end
        if package:config("libarchive") then
            package:add("deps", "libarchive")
        end
        if package:config("libcurl") then
            package:add("deps", "libcurl")
        end
        if package:config("opencl") then
            package:add("deps", "opencl")
        end
        if package:config("shared") then
            package:add("defines", "TESS_IMPORTS")
        end
    end)

    on_install("windows|x86", "windows|x64", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "find_package(PkgConfig)", "", {plain = true})
        io.replace("src/training/CMakeLists.txt", "find_package(PkgConfig)", "", {plain = true})
        local configs = {"-DSW_BUILD=OFF", "-DBUILD_TESTS=OFF", "-DUSE_SYSTEM_ICU=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DWIN32_MT_BUILD=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DBUILD_TRAINING_TOOLS=" .. (package:config("training") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_ARCHIVE=" .. (package:config("libarchive") and "OFF" or "ON"))
        table.insert(configs, "-DDISABLE_CURL=" .. (package:config("libcurl") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))

        local packagedeps = {}
        if package:is_plat("macosx") then
            table.insert(packagedeps, "libtiff")
        end

        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("tesseract --version")
        assert(package:has_cxxtypes("tesseract::TessBaseAPI", {configs = {languages = "c++11"}, includes = "tesseract/baseapi.h"}))
    end)
