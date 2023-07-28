package("celero")

    set_homepage("https://github.com/DigitalInBlue/Celero")
    set_description("C++ Benchmarking Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/DigitalInBlue/Celero/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DigitalInBlue/Celero.git")
    add_versions("v2.8.5", "1f319661c4bee1f6855e45c1764be6cd38bfe27e8afa8da1ad7060c1a793aa20")
    add_versions("v2.8.2", "7d2131ba27ca5343b31f1e04777ed3e666e2ad7f785e79c960c872fc48cd5f88")

    add_patches("v2.8.2", path.join(os.scriptdir(), "patches", "2.8.2", "gcc11.patch"), "4851cc1ed85d9ee9ce000d7df9d5baabc86f83c50cff09074159239fa37ca8e9")

    add_deps("cmake")
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "CELERO_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DCELERO_TREAT_WARNINGS_AS_ERRORS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCELERO_COMPILE_DYNAMIC_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DVCPKG_CRT_LINKAGE=" .. (package:config("vs_runtime"):startswith("MT") and "static" or "dynamic"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const auto time = celero::timer::GetSystemTime();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "celero/Timer.h"}))
    end)
