package("dragonbox")
    set_homepage("https://github.com/jk-jeon/dragonbox")
    set_description("Reference implementation of Dragonbox in C++")
    set_license("Apache-2.0")

    add_urls("https://github.com/jk-jeon/dragonbox/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jk-jeon/dragonbox.git")

    add_versions("1.1.3", "09d63b05e9c594ec423778ab59b7a5aa1d76fdd71d25c7048b0258c4ec9c3384")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("CMakeLists.txt", [[set(dragonbox_directory "dragonbox-${PROJECT_VERSION}")]], "set(dragonbox_directory )", {plain = true})

        local configs = {"-DDRAGONBOX_INSTALL_TO_CHARS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                constexpr int buffer_length = 1 + // for '\0'
                    jkj::dragonbox::max_output_string_length<jkj::dragonbox::ieee754_binary64>;
                double x = 1.234;
                char buffer[buffer_length];
                char* end_ptr = jkj::dragonbox::to_chars(x, buffer);
                end_ptr = jkj::dragonbox::to_chars_n(x, buffer);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "dragonbox/dragonbox_to_chars.h"}))
    end)
