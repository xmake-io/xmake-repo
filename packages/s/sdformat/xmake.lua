package("sdformat")
    set_homepage("http://sdformat.org/")
    set_description("Simulation Description Format (SDFormat) parser and description files.")
    set_license("Apache-2.0")

    add_urls("https://github.com/gazebosim/sdformat/archive/refs/tags/sdformat16_$(version).tar.gz")
    add_urls("https://github.com/gazebosim/sdformat.git", {alias = "git"})

    add_versions("16.0.1", "4fac898700afb2953af5f8ac6b0221e4d9bc1e460aac6d4b7a5c3699c456126c")

    add_versions("git:16.0.1", "sdformat16_16.0.1")

    add_includedirs("include", "include/gz/sdformat16")

    add_deps("cmake", "gz-cmake 5.x")
    add_deps("gz-math 9.x", "urdfdom")

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "GZ_SDFORMAT_STATIC_DEFINE")
        end

        -- fix undefined reference to `console_bridge::log(char const*, int, console_bridge::LogLevel, char const*, ...)
        if not package:has_tool("cxx", "cl") then
            io.replace("src/CMakeLists.txt", "add_subdirectory(cmd)", [[
                find_package(console_bridge CONFIG REQUIRED)
                target_link_libraries(${PROJECT_LIBRARY_TARGET_NAME} PRIVATE GzURDFDOM::GzURDFDOM -Wl,--whole-archive console_bridge::console_bridge -Wl,--no-whole-archive)
                add_subdirectory(cmd)
            ]], {plain = true})
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DSKIP_PYBIND11=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char **argv) {
                auto sdf = sdf::readFile(argv[1]);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "sdf/sdf.hh"}))
    end)
