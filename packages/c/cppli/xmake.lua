package("cppli")
set_homepage("https://cppli.bearodactyl.dev")
set_description("an intuitive CLI framework for C++")

add_urls("https://github.com/TheBearodactyl/cppli.git")
add_versions("2025.10.22", "98c8c2e8ee65d7a5a6b160cf0b85ba1be39ffb05")

add_deps("cmake")

on_install(function(package)
    local configs = {}

    table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
    table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
    table.insert(configs, "-DBUILD_TESTING=OFF")
    table.insert(configs, "-DCMAKE_CXX_STANDARD=20")
    table.insert(configs, "-DCMAKE_CXX_STANDARD_REQUIRED=ON")

    import("package.tools.cmake").install(package, configs)
end)

on_test(function(package)
    assert(package:has_cxxincludes("cppli.hpp", { configs = { languages = "cxx20" } }))
    assert(package:has_cxxtypes("cli::Parser", { includes = "cppli.hpp", configs = { languages = "cxx20" } }))
end)
