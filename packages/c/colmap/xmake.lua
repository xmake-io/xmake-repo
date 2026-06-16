package("colmap")
    set_homepage("https://colmap.github.io/")
    set_description("COLMAP - Structure-from-Motion and Multi-View Stereo.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/colmap/colmap/archive/refs/tags/$(version).tar.gz", 
             "https://github.com/colmap/colmap.git")

    add_versions("4.0.4",  "200309abca2a3ee05970b1f8a48d545fc71f435dffe6764a8040f9f6f364da32")
    add_versions("3.13.0", "98a8f8cf6358774be223239a9b034cc9d55bf66c43f54fc6ddea9128a1ee197a")

    add_patches("4.x", "patches/4.0.4/deps.patch", "78d80731ee16b204153ad23b665644c10309109ef204fee0d4c643e85222863a")
    add_patches("3.x", "patches/3.13.0/deps.patch", "93f43c149b95195bf03f30b22710502faa4c26242e7a7059881464c0b1fde2e6")

    add_configs("simd",              {description = "Enable SIMD optimizations.",                   default = true,  type = "boolean"})
    add_configs("openmp",            {description = "Enable OpenMP parallelization.",               default = true,  type = "boolean"})
    add_configs("ipo",               {description = "Enable interprocedural optimization.",         default = true,  type = "boolean"})
    add_configs("cuda",              {description = "Enable CUDA, if available.",                   default = true,  type = "boolean"})
    add_configs("onnx",              {description = "Enable ONNX, if available.",                   default = true,  type = "boolean"})
    add_configs("gui",               {description = "Enable the graphical UI.",                     default = false, type = "boolean"})
    add_configs("mvs",               {description = "Enable the Multi-View Stereo module.",         default = true,  type = "boolean"})
    add_configs("opengl",            {description = "Enable OpenGL, if available.",                 default = true,  type = "boolean"})
    add_configs("coverage",          {description = "Enable code coverage.",                        default = false, type = "boolean"})
    add_configs("asan",              {description = "Enable AddressSanitizer flags.",               default = false, type = "boolean"})
    add_configs("tsan",              {description = "Enable ThreadSanitizer flags.",                default = false, type = "boolean"})
    add_configs("ubsan",             {description = "Enable UndefinedBehaviorSanitizer flags.",     default = false, type = "boolean"})
    add_configs("profiling",         {description = "Enable google-perftools linker flags.",        default = false, type = "boolean"})
    add_configs("werror",            {description = "Treat compiler warnings as errors.",           default = false, type = "boolean"})
    add_configs("cgal",              {description = "Enable the CGAL library.",                     default = true,  type = "boolean"})
    add_configs("lsd",               {description = "Enable the LSD library.",                      default = true,  type = "boolean"})
    add_configs("benchmark",         {description = "Enable runtime benchmarking support.",         default = false, type = "boolean"})
    add_configs("caspar",            {description = "Enable CASPAR-accelerated bundle adjustment.", default = false, type = "boolean"})
    add_configs("caspar_use_double", {description = "Use double precision in Caspar solver.",       default = false, type = "boolean"})

    add_deps("ceres-solver", "cmake", "eigen", "faiss", "flann", "glew", "glog", "metis", "pkgconf", "poselib", "sqlite3")
    add_deps("boost", {configs = { graph = true, program_options = true, system = true }})

    on_load(function (package)
        local confs = {"cgal", "opengl", "openmp"}
        for _, conf in ipairs(confs) do
            if package:config(conf) then
                package:add("deps", conf)
            end
        end
        package:add("deps", package:version():ge("4.0") and "openimageio" or "freeimage")
    end)

    on_install("windows|x64", "linux", "macosx", function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DTESTS_ENABLED=OFF",
            "-DDOWNLOAD_ENABLED=OFF",
            "-DUNINSTALL_ENABLED=OFF",
            "-DFETCH_POSELIB=OFF",
            "-DFETCH_FAISS=OFF",
            "-DFETCH_ONNX=OFF",
        }
        local confs = {"simd", "openmp", "ipo", "cuda", "onnx", "gui", "mvs", "opengl", "coverage", "asan", "tsan", "ubsan", "profiling", "werror", "cgal", "lsd", "benchmark", "caspar", "caspar_use_double"}
        for _, conf in ipairs(confs) do
            table.insert(configs, "-D" .. conf:upper() .. "_ENABLED=" .. (package:config(conf) and "ON" or "OFF"))
        end
        local opt = package:version():ge("4.0") and {packagedeps = {"minizip-ng"}} or {}
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <colmap/util/string.h>
            void test() {
                std::string message = "colmap";
                std::string formatted = colmap::StringPrintf("Hello %s!", message.c_str());
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
