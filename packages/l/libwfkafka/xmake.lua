package("libwfkafka")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Workflow's Kafka Client")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")
    add_versions("v0.9.10", "7a0a9b184a6baa745235fc8b0cb59f6289111049b14f38657379ad6c029e6aaa")

    add_deps("cmake", "openssl", "workflow", "lz4", "zstd", "snappy")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    add_links("wfkafka")

    on_install("linux", "macosx", "android", function (package)
        local configs = {"-DKAFKA=y"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("android") then
            io.replace("src/CMakeLists.txt", "add_subdirectory(client)", "add_subdirectory(client)\nlink_libraries(ssl crypto)", {plain = true})
        end
        local packagedeps = {}
        if package:is_plat("android") then
            table.insert(packagedeps, "openssl")
        end
        table.join2(packagedeps, "workflow", "lz4", "zstd", "snappy")
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
            os.tryrm(path.join(package:installdir("lib"), "*.dylib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("protocol::KafkaToppar", {configs = {languages = "c++11"}, includes = "workflow/KafkaMessage.h"}))
    end)
