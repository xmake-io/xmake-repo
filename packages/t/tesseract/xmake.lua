package("tesseract")

    set_homepage("https://tesseract-ocr.github.io/")
    set_description("Tesseract Open Source OCR Engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/tesseract-ocr/tesseract/archive/$(version).tar.gz",
             "https://github.com/tesseract-ocr/tesseract.git")
    add_versions("4.1.1", "2a66ff0d8595bff8f04032165e6c936389b1e5727c3ce5a27b3e059d218db1cb")
    add_versions("4.1.3", "83dc56b544be938983f528c777e4e1d906205b0f6dc0110afc223f2cc1cec6d3")
    add_versions("5.0.1","eba4deb2f92a3f89a6623812074af8c53b772079525b3c263aa70bbf7b748b3c")
    add_versions("5.2.0","eba4deb2f92a3f89a6623812074af8c53b772079525b3c263aa70bbf7b748b3c")

    add_configs("training", {description = "Build training tools.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("leptonica")
    add_deps("libarchive", {optional = true})
    on_load("windows", "linux", function (package)
        if package:config("training") then
            package:add("deps", "icu4c")
        end
        if package:config("shared") then
            package:add("defines", "TESS_IMPORTS")
        end
    end)

    on_install("windows", "linux", function (package)
        io.replace("CMakeLists.txt", "find_package(PkgConfig)", "", {plain = true})
        io.replace("src/training/CMakeLists.txt", "find_package(PkgConfig)", "", {plain = true})
        local configs = {"-DSW_BUILD=OFF", "-DBUILD_TESTS=OFF", "-DUSE_SYSTEM_ICU=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DWIN32_MT_BUILD=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DBUILD_TRAINING_TOOLS=" .. (package:config("training") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("tesseract --version")
        assert(package:has_cxxtypes("tesseract::TessBaseAPI", {configs = {languages = "c++11"}, includes = "tesseract/baseapi.h"}))
    end)
