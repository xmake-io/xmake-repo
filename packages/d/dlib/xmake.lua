package("dlib")
    set_homepage("https://dlib.net")
    set_description("A toolkit for making real world machine learning and data analysis applications in C++")
    set_license("Boost")

    add_urls("https://github.com/davisking/dlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/davisking/dlib.git")

    add_versions("v20.0", "705749801c7896f5c19c253b6be639f4cef2c1831a9606955f01b600b3d86d80")
    add_versions("v19.24.9", "65ff8debc3ffea84430bdd4992982082caf505404e16d986b7493c00f96f44e9")
    add_versions("v19.24.8", "819cfd28639fe80ca28039f591a15e01772b7ada479de4a002b95bcb8077ce80")
    add_versions("v19.24.6", "22513c353ec9c153300c394050c96ca9d088e02966ac0f639e989e50318c82d6")
    add_versions("v19.24.5", "01cab8fb880cf4d1cb9c84cb74c6ce291a78c69f443dced5aa2a88fb20bdc3bd")
    add_versions("v19.24.4", "d881911d68972d11563bb9db692b8fcea0ac1b3fd2e3f03fa0b94fde6c739e43")
    add_versions("v19.22", "5f44b67f762691b92f3e41dcf9c95dd0f4525b59cacb478094e511fdacb5c096")

    add_configs("png", {description = "Enable png", default = false, type = "boolean"})
    add_configs("jpg", {description = "Enable jpg", default = false, type = "boolean"})
    add_configs("gif", {description = "Enable gif", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Enable sqlite3", default = false, type = "boolean"})
    add_configs("blas", {description = "Enable blas", default = false, type = "boolean"})
    add_configs("lapack", {description = "Enable lapack", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable cuda", default = false, type = "boolean"})
    add_configs("mkl", {description = "Enable mkl", default = false, type = "boolean"})
    add_configs("jxl", {description = "Enable jpeg xl", default = false, type = "boolean"})
    add_configs("ffmpeg", {description = "Enable ffmpeg", default = false, type = "boolean"})
    add_configs("webp", {description = "Enable webp", default = false, type = "boolean"})

    add_configs("simd", {description = "SIMD acceleration architecture.", type = "string", values = {"sse2", "sse4", "avx", "neon"}})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("png") then
            package:add("deps", "libpng")
        end
        if package:config("jpg") then
            package:add("deps", "libjpeg")
        end
        if package:config("gif") then
            package:add("deps", "giflib")
        end
        if package:config("sqlite3") then
            package:add("deps", "sqlite3")
        end
        if package:config("blas") then
            package:add("deps", "openblas")
        end
        if package:config("lapack") then
            package:add("deps", "lapack")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("mkl") then
            package:add("deps", "mkl")
        end
        if package:config("jxl") then
            package:add("deps", "libjxl")
        end
        if package:config("ffmpeg") then
            package:add("deps", "ffmpeg")
        end
        if package:version():ge("19.24") and package:config("webp") then
            package:add("deps", "libwebp")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DDLIB_IN_PROJECT_BUILD=OFF",
            "-DDLIB_ISO_CPP_ONLY=OFF",
            "-DDLIB_NO_GUI_SUPPORT=ON"
        }
        if package:is_plat("windows") then
            if package:is_debug() then
                table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            end
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
                io.replace("dlib/CMakeLists.txt", [[message(FATAL_ERROR "Building dlib as a standalone dll is not supported when using Visual Studio.  You are highly encouraged to use static linking instead.  See https://github.com/davisking/dlib/issues/1483 for a discussion.")]], "", {plain = true})
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DDLIB_PNG_SUPPORT=" .. (package:config("png") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_JPEG_SUPPORT=" .. (package:config("jpg") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_GIF_SUPPORT=" .. (package:config("jpg") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_LINK_WITH_SQLITE3=" .. (package:config("sqlite3") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_USE_BLAS=" .. (package:config("blas") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_USE_LAPACK=" .. (package:config("lapack") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_USE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_USE_MKL_FFT=" .. (package:config("mkl") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_JXL_SUPPORT=" .. (package:config("jxl") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_USE_FFMPEG=" .. (package:config("ffmpeg") and "ON" or "OFF"))
        table.insert(configs, "-DDLIB_WEBP_SUPPORT=" .. (package:config("webp") and "ON" or "OFF"))

        local simd = package:config("simd")
        table.insert(configs, "-DUSE_NEON_INSTRUCTIONS=" .. ((simd == "neon") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SSE2_INSTRUCTIONS=" .. ((simd == "sse2") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SSE4_INSTRUCTIONS=" .. ((simd == "sse4") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_AVX_INSTRUCTIONS=" .. ((simd == "avx") and "ON" or "OFF"))
        if simd == "sse4" then
            package:add("defines", "DLIB_HAVE_SSE2", "DLIB_HAVE_SSE3", "DLIB_HAVE_SSE41")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("dlib::command_line_parser", {
            includes = "dlib/cmd_line_parser.h", configs = {languages = "c++14"}}))
    end)
