package("aws-sdk-cpp")
    set_homepage("https://github.com/aws/aws-sdk-cpp")
    set_description("AWS SDK for C++")

    add_urls("https://github.com/aws/aws-sdk-cpp.git")
    add_versions("1.9.333", "6ec095fa11379174da20bf1523c93c92503eb8e2")

    add_configs("build_only", {description = 'By default, all SDKS are built, if AWS S3 is required, then set build_only="s3", with multiple SDKS separated by commas.'})
    add_deps("cmake")
    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_ONLY=" .. (package:config("build_only") or ""))
        import("package.tools.cmake").install(package, configs)
    end)
