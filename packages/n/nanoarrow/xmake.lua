package("nanoarrow")
    set_homepage("https://arrow.apache.org/nanoarrow")
    set_description("Helpers for Arrow C Data & Arrow C Stream interfaces")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/arrow-nanoarrow/archive/refs/tags/apache-arrow-nanoarrow-$(version).tar.gz",
             "https://github.com/apache/arrow-nanoarrow.git")

    add_versions("0.6.0", "775cbad57d5b1802da773cb568edffde72560ad4b8ad2322bc73da93374cd673")

    add_configs("ipc", {description = "Build IPC extension", default = false, type = "boolean"})
    add_configs("device", {description = "Build device extension", default = false, type = "boolean"})
    add_configs("cuda", {description = "Build cuda with device extension", default = false, type = "boolean"})
    if is_plat("macosx") then
        add_configs("metal", {description = "Build Apple metal with device extension", default = false, type = "boolean"})
    end

    add_links("nanoarrow_ipc", "nanoarrow_device", "nanoarrow")

    add_deps("cmake")

    on_load(function (package)
        if package:config("ipc") then
            package:add("deps", "flatcc")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install(function (package)
        if package:config("ipc") then
            io.replace("CMakeLists.txt", "if(NOT NANOARROW_FLATCC_INCLUDE_DIR AND NOT NANOARROW_FLATCC_ROOT_DIR)", "if(0)", {plain = true})
            io.replace("CMakeLists.txt", "PRIVATE flatccrt", "", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DNANOARROW_IPC=" .. (package:config("ipc") and "ON" or "OFF"))
        table.insert(configs, "-DNANOARROW_DEVICE=" .. (package:config("device") and "ON" or "OFF"))
        table.insert(configs, "-DNANOARROW_DEVICE_WITH_METAL=" .. (package:config("metal") and "ON" or "OFF"))
        table.insert(configs, "-DNANOARROW_DEVICE_WITH_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))

        local opt = {}
        if package:config("ipc") then
            opt.packagedeps = "flatcc"
        end
        import("package.tools.cmake").install(package, configs, opt)

        os.trymv(package:installdir("lib/*.dll"), package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ArrowMalloc", {includes = "nanoarrow/nanoarrow.h"}))
    end)
