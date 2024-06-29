package("pe-parse")
    set_homepage("https://github.com/trailofbits/pe-parse")
    set_description("Principled, lightweight C/C++ PE parser")
    set_license("MIT")

    add_urls("https://github.com/trailofbits/pe-parse/archive/f2f0ee91f3b6dee41f75b2f775e82015f2b72007.tar.gz",
             "https://github.com/trailofbits/pe-parse.git")

    add_versions("2024.06.04", "f20594916452f868a55928ef99945dbbd416387e320101b1bf63f9dcff4af628")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        io.replace("cmake/compilation_flags.cmake", "-Werror", "", {plain = true})
        if package:is_plat("windows") and package:is_arch("arm.*") then
            io.replace("CMakeLists.txt", "find_package(Filesystem COMPONENTS Experimental Final REQUIRED)", "", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_COMMAND_LINE_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::string str = peparse::GetPEErrString();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pe-parse/parse.h"}))
    end)
