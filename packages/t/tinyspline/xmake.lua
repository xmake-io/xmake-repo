package("tinyspline")
    set_homepage("https://github.com/msteinbeck/tinyspline")
    set_description("ANSI C library for NURBS, B-Splines, and Bézier curves with interfaces for C++, C#, D, Go, Java, Javascript, Lua, Octave, PHP, Python, R, and Ruby.")
    set_license("MIT")

    add_urls("https://github.com/msteinbeck/tinyspline/archive/refs/tags/$(version).tar.gz",
             "https://github.com/msteinbeck/tinyspline.git")

    add_versions("v0.6.0", "3ea31b610dd279266f26fd7ad5b5fca7a20c0bbe05c7c32430ed6aa54d57097a")

    add_deps("cmake")

    on_install(function (package)
        io.replace("src/CMakeLists.txt", [["lib64"]], [["lib"]], {plain = true})
        io.replace("src/CMakeLists.txt", "RUNTIME DESTINATION ${TINYSPLINE_INSTALL_BINARY_DIR}", "RUNTIME DESTINATION bin", {plain = true})
        io.replace("src/CMakeLists.txt", "LIBRARY DESTINATION ${TINYSPLINE_INSTALL_LIBRARY_DIR}", "LIBRARY DESTINATION lib", {plain = true})
        io.replace("src/CMakeLists.txt", "ARCHIVE DESTINATION ${TINYSPLINE_INSTALL_LIBRARY_DIR}", "ARCHIVE DESTINATION lib", {plain = true})
        local configs = {
            "-DTINYSPLINE_BUILD_EXAMPLES=OFF", "-DTINYSPLINE_BUILD_TESTS=OFF", 
            "-DTINYSPLINE_BUILD_DOCS=OFF",  "-DTINYSPLINE_WARNINGS_AS_ERRORS=OFF"
        }
        -- Fix for mingw@macosx being recognized as Windows
        if package:is_plat("mingw") and is_subhost("macosx") then
            table.insert(configs, "-DCMAKE_SYSTEM_NAME=Linux")
        end
        -- Fix for newer WASM/Emscripten versions
        io.replace("src/tinysplinecxx.h", "toWireType(const std::vector<T, Allocator> &vec)", "toWireType(const std::vector<T, Allocator> &vec, rvp::default_tag)", {plain = true})
        io.replace("src/tinysplinecxx.h", "return ValBinding::toWireType(val::array(vec))", "return ValBinding::toWireType(val::array(vec), rvp::default_tag{})", {plain = true})
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ts_deboornet_free", {includes = "tinyspline.h"}))
    end)
