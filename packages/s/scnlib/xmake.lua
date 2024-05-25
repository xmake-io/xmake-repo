package("scnlib")
    set_homepage("https://scnlib.readthedocs.io/")
    set_description("scnlib is a modern C++ library for replacing scanf and std::istream")
    set_license("Apache-2.0")

    add_urls("https://github.com/eliaskosunen/scnlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eliaskosunen/scnlib.git")

    add_versions("v2.0.3", "507ed0e988f1d9460a9c921fc21f5a5244185a4015942f235522fbe5c21e6a51")
    add_versions("v2.0.2", "a485076b8710576cf05fbc086d39499d16804575c0660b0dfaeeaf7823660a17")
    add_versions("v1.1.2", "5ed3ec742302c7304bf188bde9c4012a65dc8124ff4e1a69b598480d664250e6")
    add_versions("v0.4", "f23e66b00c9d38671b39b83c082a5b2db1cf05b3e3eff7b4a769487d9ed9d366")

    add_configs("header_only", {description = "Use header only version. (deprecated after v2.0.0)", default = false, type = "boolean"})
    add_configs("exceptions", {description = "Enable exception handling", default = true, type = "boolean"})
    add_configs("rtti", {description = "Enable rtti", default = true, type = "boolean"})
    add_configs("regex", {description = "Regex backend to use", type = "string", values = {"std", "boost", "re2"}})

    add_deps("fast_float")

    on_load(function (package)
        if package:config("header_only") and package:version():lt("2.0.0") then
            package:set("kind", "library", {headeronly = true})
            package:add("defines", "SCN_HEADER_ONLY=1")
        else
            package:add("deps", "cmake")
        end

        if package:version():ge("2.0.3") then
            package:add("links", "scn", "simdutf")
        else
            package:add("deps", "simdutf")
        end

        local regex = package:config("regex")
        if regex and regex ~= "std" then
            package:add("deps", regex)
        end
    end)

    on_install(function (package)
        if package:config("header_only") and package:version():lt("2.0.0") then
            os.cp("include/scn", package:installdir("include"))
            return
        end

        local configs = {
            "-DSCN_DISABLE_TOP_PROJECT=ON",
            "-DSCN_INSTALL=ON",
            "-DSCN_TESTS=OFF",
            "-DSCN_DOCS=OFF",
            "-DSCN_EXAMPLES=OFF",
            "-DSCN_BENCHMARKS=OFF",
            "-DSCN_PENDANTIC=OFF",
            "-DSCN_BUILD_FUZZING=OFF",

            "-DSCN_USE_EXTERNAL_FAST_FLOAT=ON"
        }

        if package:version():le("2.0.2") then
            io.replace("cmake/dependencies.cmake", "simdutf 4.0.0", "simdutf", {plain = true})
            table.insert(configs, "-DSCN_USE_EXTERNAL_SIMDUTF=ON")
        end

        local regex = package:config("regex")
        if regex then
            table.insert(configs, "-DSCN_DISABLE_REGEX=OFF")
            if regex == "boost" then
                regex = "Boost"
            end
            table.insert(configs, "-DSCN_REGEX_BACKEND=" .. regex)
        else
            table.insert(configs, "-DSCN_DISABLE_REGEX=ON")
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSCN_USE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        table.insert(configs, "-DSCN_USE_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))
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
                if (const auto result = scn::prompt<int>("What's your favorite number? ", "{}")) {
                    std::printf("%d, interesting\n", result->value());
                }
            }
        ]]}, {configs = {languages = "c++17"}, includes = "scn/scan.h"}))
    end)
