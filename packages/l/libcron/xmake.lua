package("libcron")
    set_homepage("https://github.com/PerMalmberg/libcron")
    set_description("A C++ scheduling library using cron formatting.")
    set_license("MIT")

    add_urls("https://github.com/PerMalmberg/libcron/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PerMalmberg/libcron.git")

    add_versions("v1.3.3", "7d413b7950c82b54157b2a7f446e1e660bd718e542e2ffd3f8715e467ab2b825")
    add_versions("v1.3.1", "cf5af6af392df29c8fc61fcc5a8e452118f31f47d7aa92eb7d4f4183dea227c8")

    add_deps("cmake")
    add_deps("date")

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_dependencies(cron_test libcron)", "", {plain = true})
        io.replace("CMakeLists.txt", "install(DIRECTORY libcron/externals/date/include/date DESTINATION include)", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {packagedeps = "date"}
        if package:is_plat("windows") then
            opt.cxflags = "-DWIN32"
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                libcron::CronData cron;
                cron.create("");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "libcron/CronData.h"}))
    end)
