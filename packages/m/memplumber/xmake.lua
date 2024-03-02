package("memplumber")
    set_homepage("https://github.com/seladb/MemPlumber")
    set_description("MemPlumber is a library that helps developers with debugging of memory allocations and detection of memory leaks in C++ applications")
    set_license("MIT")

    add_urls("https://github.com/seladb/MemPlumber.git")
    add_versions("2022.01.27", "ff04d339b034c40f72e09653c6a0340c0bb05d3b")

    if is_plat("linux", "macosx") then
        add_deps("libbacktrace")
    end

    add_configs("collect_static_var_data", {description = "Collect data also on static variable memory allocation", default = false, type = "boolean"})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            option("collect_static_var_data", {description = "Collect data also on static variable memory allocation", default = false, type = "boolean"})
            if is_plat("linux", "macosx") then
                add_requires("libbacktrace")
            end
            target("memplumber")
                set_kind("$(kind)")
                set_languages("cxx11")
                if is_plat("linux", "macosx") then
                    add_packages("libbacktrace")
                elseif is_plat("windows") then
                    add_defines("_WIN32")
                end
                add_files("memplumber.cpp")
                add_headerfiles("(memplumber.h)", "memplumber-internals.h")
                if has_config("collect_static_var_data") then
                    add_defines("COLLECT_STATIC_VAR_DATA")
                end
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <memplumber.h>
            void test() {
                MemPlumber::start();
                int* num = new int(100);

                size_t memLeakCount;
                uint64_t memLeakSize;
                MemPlumber::memLeakCheck(memLeakCount, memLeakSize, true);

                MemPlumber::stopAndFreeAllMemory();
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
