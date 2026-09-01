package("pangolin")
    set_homepage("https://github.com/stevenlovegrove/Pangolin")
    set_description("Pangolin is a lightweight portable rapid development library for managing OpenGL display / interaction and abstracting video input.")
    set_license("MIT")

    add_urls("https://github.com/stevenlovegrove/Pangolin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stevenlovegrove/Pangolin.git", {submodules = false})

    add_versions("v0.9.4", "fb95a354dc64bb151881192703db461a59089f7bcdb2c2c9185cfb5393586d97")

    add_configs("libpng",  { description = "Build support for libpng image input",  default = false, type = "boolean"})
    add_configs("libjpeg", { description = "Build support for libjpeg image input", default = false, type = "boolean"})
    add_configs("libtiff", { description = "Build support for libtiff image input", default = false, type = "boolean"})
    add_configs("openexr", { description = "Build support for OpenEXR image input", default = false, type = "boolean"})
    add_configs("lz4",     { description = "Build support for lz4 compression",     default = false, type = "boolean"})
    add_configs("zstd",    { description = "Build support for zstd compression",    default = false, type = "boolean"})
    add_configs("libraw",  { description = "Build support for libraw (raw images)", default = false, type = "boolean"})

    add_configs("libdc1394",           { description = "Build support for libdc1394 video input",               default = false, type = "boolean"})
    add_configs("v4l",                 { description = "Build support for V4L video input (Linux only)",        default = false, type = "boolean"})
    add_configs("ffmpeg",              { description = "Build support for ffmpeg video input",                  default = false, type = "boolean"})
    add_configs("realsense",           { description = "Build support for RealSense video input",               default = false, type = "boolean"})
    add_configs("realsense2",          { description = "Build support for RealSense2 video input",              default = false, type = "boolean"})
    add_configs("openni",              { description = "Build support for OpenNI video input",                  default = false, type = "boolean"})
    add_configs("openni2",             { description = "Build support for OpenNI2 video input",                 default = false, type = "boolean"})
    add_configs("libuvc",              { description = "Build support for libuvc video input",                  default = false, type = "boolean"})
    add_configs("uvc_mediafoundation", { description = "Build support for MediaFoundation UVC input (Windows)", default = false, type = "boolean"})
    add_configs("depthsense",          { description = "Build support for DepthSense video input",              default = false, type = "boolean"})
    add_configs("telicam",             { description = "Build support for TeliCam video input",                 default = false, type = "boolean"})
    add_configs("pleora",              { description = "Build support for Pleora video input",                  default = false, type = "boolean"})

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_links(
        "pango_plot", "pango_tools", "pango_display", "pango_scene", "pango_geometry", "pango_glgeometry",
        "pango_windowing", "pango_vars", "pango_opengl", "pango_image", "pango_video", "pango_packetstream", "pango_core",
        "tinyobj"
    )

    if is_plat("linux", "bsd") then
        add_syslinks("EGL", "pthread", "rt")
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi", "gdi32", "user32", "shell32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "OpenGL")
    end

    add_deps("cmake")
    add_deps("eigen")
    if is_plat("linux") then
        add_deps("libepoxy")
    elseif not is_plat("wasm") then
        add_deps("glew")
    end
    -- TODO: unbundle sigslot tinyobjloader
    local deps = {
        "libpng",
        "libjpeg",
        "libtiff",
        "openexr",
        "lz4",
        "zstd",
        "libraw",

        "libdc1394",
        "v4l",
        "ffmpeg",
        "realsense",
        "realsense2",
        "openni",
        "openni2",
        "libuvc",
        "uvc_mediafoundation",
        "depthsense",
        "telicam",
        "pleora",
    }

    on_load(function (package)
        for _, dep in ipairs(deps) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end

        package:add("defines", "HAVE_EIGEN")
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
        io.replace("CMakeLists.txt", "-Werror=maybe-uninitialized", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror=vla", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        if package:config("libraw") then
            io.replace("cmake/FindLibraw.cmake", "NAMES raw_r", "NAMES raw", {plain = true})
            io.replace("components/pango_image/CMakeLists.txt", "libraw_INCLUDE_DIR", "libraw_INCLUDE_DIRS", {plain = true})
            if not package:dep("libraw"):config("shared") then
                io.replace("components/pango_image/CMakeLists.txt", "HAVE_LIBRAW", "HAVE_LIBRAW LIBRAW_NODLL", {plain = true})
            end
        end
        -- fix gcc15
        io.replace("components/pango_core/include/pangolin/factory/factory.h", "#include <map>", "#include <map>\n#include <cstdint>", {plain = true})

        local glew = package:dep("glew")
        if glew and not glew:config("shared") and package:is_plat("mingw") then
            io.replace("components/pango_opengl/CMakeLists.txt",
                "target_link_libraries(${COMPONENT} PUBLIC ${GLEW_LIBRARY})",
                "target_link_libraries(${COMPONENT} PRIVATE ${GLEW_LIBRARY})", {plain = true})
        end

        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_PANGOLIN_PYTHON=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:is_debug() and package:config("shared") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=")
        end

        for _, dep in ipairs(deps) do
            local name = dep
            if dep == "openexr" then
                name = "libopenexr"
            end
            table.insert(configs, format("-DBUILD_PANGOLIN_%s=%s", name:upper(), (package:config(dep) and "ON" or "OFF")))
        end
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        if glew and not glew:config("shared") and package:is_plat("windows", "mingw") then
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
