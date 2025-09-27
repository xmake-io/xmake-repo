package("glgpuselect")
    set_homepage("https://github.com/ArthurVasseur/GLGpuSelect")
    set_description("GLGpuSelect is a cross-platform drop-in replacement for opengl32.dll on Windows and libGL.so on Linux that enables per-application GPU selection ")
    set_license("GPL-3.0")

    add_urls("https://github.com/ArthurVasseur/GLGpuSelect/archive/refs/tags/$(version).zip",
             "https://github.com/ArthurVasseur/GLGpuSelect.git")
    add_versions("0.1.2", "9c5ab5333f8b6acbcd1022943d6f2edd41727429ea063c8187137b3c6524aae7")
    add_versions("0.1.1", "29c9f2a0e879605abdf69e72ff008716dbba18865974761df5c887647b0ad774")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("profiling", {description = "Build with tracy profiler", default = false, type = "boolean"})
    add_configs("asserts", {description = "Enable asserts", default = false, type = "boolean"})
    add_configs("logging", {description = "Enable logging", default = false, type = "boolean"})

    add_deps("concerto-core")

    on_load(function (package)
        if package:config("profiling") then
            package:add("deps", "tracy")
        end
    end)

    on_install("windows", function (package)
        local configs = {
            profiling = package:config("profiling"),
            asserts = package:config("asserts"),
            logging = package:config("logging"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <GLGpuSelect.h>
            
            void test() {
                uint32_t deviceCount = 0;
                uint32_t result = glgpusEnumerateDevices(&deviceCount, NULL);
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
