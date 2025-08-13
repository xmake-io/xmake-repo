package("glgpuselect")
    set_homepage("https://github.com/ArthurVasseur/GLGpuSelect")
    set_description("GLGpuSelect is a cross-platform drop-in replacement for opengl32.dll on Windows and libGL.so on Linux that enables per-application GPU selection ")
    set_license("GPL-3.0")

    add_urls("https://github.com/ArthurVasseur/GLGpuSelect/archive/refs/tags/$(version).zip",
             "https://github.com/ArthurVasseur/GLGpuSelect.git")
    add_versions("0.1.0", "8f3b619c7cb33cfbf84bb2657a48ac6862b7593df85cd4ca289f58681932e738")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("profiling", {description = "Build with tracy profiler", default = false, type = "boolean"})
    add_configs("asserts", {description = "Enable asserts", default = false, type = "boolean"})
    add_configs("logging", {description = "Enable logging", default = false, type = "boolean"})

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
