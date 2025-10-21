package("oboe")
    set_homepage("https://github.com/google/oboe")
    set_description("Oboe is a C++ library that makes it easy to build high-performance audio apps on Android.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/oboe/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/oboe.git")

    add_versions("1.10.0", "0e4245f8860c4287040a5d76501c588490bcc9cb57614c486c0c201a5dde3e9f")
    add_versions("1.9.3", "9d2486b74bd396d9d9112625077d5eb656fd6942392dc25ebf222b184ff4eb61")
    add_configs("cmake", {description = "Use cmake build system", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install("android", function (package)
        if package:config("cmake") then
            io.replace("CMakeLists.txt", "LIBRARY DESTINATION lib/${ANDROID_ABI}", "LIBRARY DESTINATION lib", {plain = true})
            io.replace("CMakeLists.txt", "ARCHIVE DESTINATION lib/${ANDROID_ABI}", "ARCHIVE DESTINATION lib", {plain = true})
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            io.writefile("xmake.lua", [[
                add_rules("mode.release", "mode.debug")
                add_rules("utils.install.cmake_importfiles")
                option("version", {description = "Set the version"})
                set_version(get_config("version"))
                target("oboe")
                    set_kind("$(kind)")
                    set_languages("c++17")
                    add_files("src/**.cpp")
                    add_includedirs("include", "src")
                    add_headerfiles("include/(oboe/*.h)")
                    if is_mode("debug") then
                        set_optimize("fastest")
                        add_defines("OBOE_ENABLE_LOGGING=1")
                    else
                        set_optimize("aggressive")
                    end
                    add_defines("DO_NOT_DEFINE_OPENSL_ES_CONSTANTS=0")
                    add_syslinks("log", "OpenSLES")
                    add_ldflags("-Wl,-z,max-page-size=16384")
            ]])
            import("package.tools.xmake").install(package, {version = package:version()})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                oboe::FifoBuffer * buf = new oboe::FifoBuffer(4, 10240);
                auto bytes = buf->convertFramesToBytes(32);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "oboe/Oboe.h"}))
    end)
