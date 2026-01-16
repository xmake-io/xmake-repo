package("openjph")
    set_homepage("https://github.com/aous72/OpenJPH")
    set_description("Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K)")
    set_license("BSD-2-Clause")
    
    add_urls("https://github.com/aous72/OpenJPH/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aous72/OpenJPH.git")

    add_versions("0.26.0", "359fa26e5c6becc64f7f9fa339600e00ca3164af7d988aa1fbf16d527347baf4")
    add_versions("0.25.2", "ae5f09562cb811cb2fb881c5eb74583e18db941848cfa3c35787e2580f3defc6")
    add_versions("0.24.2", "c99218752b15b5b2afca3b0e4d4f0ddf1ac19f94dbcbe11874fe492d44ed3e2d")
    add_versions("0.24.1", "5e44a809c9ee3dad175da839feaf66746cfc114a625ec61c786de8ad3f5ab472")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 28, "package(openjph): need ndk api level >= 28")
        end)
    end

    on_install(function (package)
        local ojph_header_path
        if package:version():lt("0.26.0") then
            ojph_header_path = "src/core/common"
        else
            ojph_header_path = "src/core/openjph"
        end
        if package:is_plat("windows", "mingw") and package:config("shared") then
            io.replace(path.join(ojph_header_path, "ojph_arch.h"), [[#else
#define OJPH_EXPORT
#endif]], [[#else
#define OJPH_EXPORT __declspec(dllimport)
#endif]], {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOJPH_BUILD_EXECUTABLES=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ojph::j2c_outfile file;
                file.open("file.txt");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "openjph/ojph_file.h"}))
    end)
