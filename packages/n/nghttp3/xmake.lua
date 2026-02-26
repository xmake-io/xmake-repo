package("nghttp3")
    set_homepage("https://github.com/ngtcp2/nghttp3")
    set_description("HTTP/3 library written in C")
    set_license("MIT")

    add_urls("https://github.com/ngtcp2/nghttp3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ngtcp2/nghttp3.git", {submodules = false})

    add_versions("v1.15.0", "fcb7b8efb11f65bf4361df703e49db3942eba8c3a2f12c0e8fdba70c848e6350")
    add_versions("v1.14.0", "547c45ed48b477531312f4bc6cdf94efe27ed64e9fc718c3b5b675bd5fbf3257")
    add_versions("v1.13.1", "d21c0dcf322e2507998bfa49088bba2b8c876bac7846259d032a2b4077d96204")
    add_versions("v1.12.0", "cefeb231f58c27258548f4c7aab2e5c5921b44631c384c750c3dc5592c6c7d7c")
    add_versions("v1.11.0", "2fc58fbb8a4b463e62ce985dbc6ef5e215bfd41dc23ee625225e0589b97ac82a")
    add_versions("v1.10.1", "6d8714b9a077e02c17b85a0a5d8e90ceb26e9c91b149d3238130a91ca3df3e3a")
    add_versions("v1.8.0", "d2cac7cd17966c915f87fa6b823963db4b555397e43c69d16d289765af7ab442")
    add_versions("v1.7.0", "2e6c5599995939a96b759e9f8987c69c0872ed1c219f57730685a93c1c36c9ef")
    add_versions("v1.6.0", "7062b50ed7118566fc39cf9629e44de7582e77b43611f7e10d3ab192c91acb72")
    add_versions("v1.5.0", "8b4f47164fab6f9c6c1e77a61942d57e26e135731c9876ba6acf973f54cf78fe")
    add_versions("v1.4.0", "522c8952ccae1815f34425f0c8bc6d8a4660e72dada1b4e97b8223e4c459a84a")
    add_versions("v1.3.0", "a83c6a4f589ae777a5f967652969d99b3399a85971340b8de9bed79119a11f88")

    add_patches(">=1.4.0<1.11.0", "patches/1.4.0/vendor.patch", "a6d611938c797d721a0345c5c772a1405ae0d6587ae46e16c1b73c89090a5c08")
    add_patches("1.3.0", "patches/1.3.0/vendor.patch", "51ab785328270b8df854283a8c20403c09813b0586eb84702a9c20241ff14980")

    add_deps("cmake")

    on_load(function (package)
        if package:version() and package:version():ge("1.7.0") then
            package:add("deps", "sfparse")
        else
            package:add("deps", "sfparse 2024.05.12")
        end

        if not package:config("shared") then
            package:add("defines", "NGHTTP3_STATICLIB")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        if package:version() and package:version():ge("1.11.0") then
            io.replace("lib/CMakeLists.txt", "sfparse/sfparse.c", "", {plain = true})
            io.replace("lib/CMakeLists.txt",
                "add_library(nghttp3 SHARED ${nghttp3_SOURCES})",
                "add_library(nghttp3 SHARED ${nghttp3_SOURCES})\ntarget_link_libraries(nghttp3 sfparse)", {plain = true})
            io.replace("lib/CMakeLists.txt",
                "add_library(nghttp3_static STATIC ${nghttp3_SOURCES})",
                "add_library(nghttp3_static STATIC ${nghttp3_SOURCES})\ntarget_link_libraries(nghttp3_static sfparse)", {plain = true})
        end

        local configs = {"-DENABLE_LIB_ONLY=ON", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_STATIC_CRT=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "sfparse"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nghttp3_version", {includes = "nghttp3/nghttp3.h"}))
    end)
