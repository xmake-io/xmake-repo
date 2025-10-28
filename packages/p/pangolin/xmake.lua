package("pangolin")
    set_homepage("https://github.com/stevenlovegrove/Pangolin")
    set_description("Pangolin is a lightweight portable rapid development library for managing OpenGL display / interaction and abstracting video input.")
    set_license("MIT")

    add_urls("https://github.com/stevenlovegrove/Pangolin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stevenlovegrove/Pangolin.git", {submodules = false})

    add_versions("v0.9.4", "fb95a354dc64bb151881192703db461a59089f7bcdb2c2c9185cfb5393586d97")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt")
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi", "gdi32", "user32", "shell32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa")
    end

    add_deps("cmake")
    add_deps("eigen")
    if not is_plat("wasm", "linux") then
        add_deps("glew")
    elseif is_plat("linux") then
        add_deps("libepoxy")
    end
    -- TODO: unbundle sigslot tinyobjloader

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "_WIN_")
        elseif package:is_plat("linux") then
            package:add("defines", "_LINUX_")
        elseif package:is_plat("macosx") then
            package:add("defines", "_OSX_")
        elseif package:is_plat("wasm") then
            package:add("defines", "_EMSCRIPTEN_")
        end

        if package:is_plat("wasm") then
            package:add("defines", "HAVE_GLES", "HAVE_GLES_2", "HAVE_GLEW")
        elseif package:is_plat("linux") then
            package:add("defines", "HAVE_EPOXY")
        else
            package:add("defines", "HAVE_GLEW")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "msys", "wasm", function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        local glew = package:dep("glew")
        if glew and not glew:config("shared") then
            opt.cxflags = "-DGLEW_STATIC"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pangolin/display/display.h>
            void test() {
                pangolin::CreateWindowAndBind("Classic GL Triangle", 500, 500);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
