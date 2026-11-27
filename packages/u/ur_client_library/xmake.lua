package("ur_client_library")
    set_homepage("https://github.com/UniversalRobots/Universal_Robots_Client_Library")
    set_description("A C++ library for accessing the UR interfaces that facilitate the use of UR robotic manipulators by external applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/UniversalRobots/Universal_Robots_Client_Library/archive/refs/tags/$(version).tar.gz",
             "https://github.com/UniversalRobots/Universal_Robots_Client_Library")
    add_versions("2.18.0", "885fc418767f6ff7eb37452fed94d9b38e8c2619608da14129ed19a3f827d67b")

    add_configs("asan", {description = "Compile with address sanitizer support.", default = false, type = "boolean"})
    add_configs("primary_client_strict_parsing", {description = "Enable strict parsing of primary client messages" , default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = is_plat("windows", "mingw")})
    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_install("!bsd and !wasm", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "# add_subdirectory(examples)", {plain = true})
        local configs = {
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DWITH_ASAN=" .. (package:config("asan") and "ON" or "OFF"),
            "-DPRIMARY_CLIENT_STRICT_PARSING_=" .. (package:config("primary_client_strict_parsing") and "ON" or "OFF"),
            "-DBUILDING_TESTS=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("urcl::rtde_interface::knownTypeNames()", {includes = "ur_client_library/rtde/data_type.h", configs = {languages = "c++17"}}))
    end)
