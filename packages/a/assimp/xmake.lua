package("assimp")

    set_homepage("https://assimp.org")
    set_description("Portable Open-Source library to import various well-known 3D model formats in a uniform manner")

    if is_plat("windows", "linux", "macosx") then
        set_urls("https://github.com/assimp/assimp/archive/v$(version).zip")
        add_versions("5.0.1", "d10542c95e3e05dece4d97bb273eba2dfeeedb37a78fb3417fd4d5e94d879192")
    end

    add_configs("shared",                {description = "Generation of shared libs ( dll for windows, so for Linux ). Set this to OFF to get a static lib", default = true, type = "boolean"})
    add_configs("build_framework",       {description = "Build package as Mac OS X Framework bundle (macosx only)", default = false, type = "boolean"})
    add_configs("double_precision",      {description = "All data will be stored as double values", default = false, type = "boolean"})
    add_configs("opt_build_packages",    {description = "Set to true to generate CPack configuration files and packaging targets", default = false, type = "boolean"})
    add_configs("android_jniiosysystem", {description = "Android JNI IOSystem support is active", default = false, type = "boolean"})
    add_configs("no_export",             {description = "Disable Assimp's export functionality", default = false, type = "boolean"})
    add_configs("build_zlib",            {description = "Build your own zlib", default = false, type = "boolean"})
    add_configs("build_assimp_tools",    {description = "If the supplementary tools for Assimp are built in addition to the library", default = false, type = "boolean"})
    add_configs("build_samples",         {description = "If the official samples are built as well (needs freeglut)", default = false, type = "boolean"})
    add_configs("build_tests",           {description = "If the test suite for Assimp is built in addition to the library", default = true, type = "boolean"})
    add_configs("coveralls",             {description = "Enable this to measure test coverage", default = false, type = "boolean"})
    add_configs("werror",                {description = "Treat warnings as errors", default = false, type = "boolean"})
    add_configs("asan",                  {description = "Enable AddressSanitizer", default = false, type = "boolean"})
    add_configs("ubsan",                 {description = "Enable Undefined Behavior sanitizer", default = false, type = "boolean"})
    add_configs("system_irrxml",         {description = "Use system installed Irrlicht/IrrXML library", default = false, type = "boolean"})
    add_configs("build_docs",            {description = "Build documentation using Doxygen", default = false, type = "boolean"})
    add_configs("inject_debug_postfix",  {description = "Inject debug postfix in .a/.so lib names", default = false, type = "boolean"})
    add_configs("ignore_git_hash",       {description = "Don't call git to get the hash", default = false, type = "boolean"})
    add_configs("install_pdb",           {description = "Install MSVC debug files", default = false, type = "boolean"})
    add_configs("build_all_importers",   {description = "Build all importers by default", default = true, type = "boolean"})
    add_configs("build_all_exporters",   {description = "Build all exporters by default", default = true, type = "boolean"})

    local importers = {
        "AMF",
        "3DS",
        "AC",
        "ASE",
        "ASSBIN",
        "B3D",
        "BVH",
        "COLLADA",
        "DXF",
        "CSM",
        "HMP",
        "IRRMESH",
        "IRR",
        "LWO",
        "LWS",
        "MD2",
        "MD3",
        "MD5",
        "MDC",
        "MDL",
        "NFF",
        "NDO",
        "OFF",
        "OBJ",
        "OGRE",
        "OPENGEX",
        "PLY",
        "MS3D",
        "COB",
        "BLEND",
        "IFC",
        "XGL",
        "FBX",
        "Q3D",
        "Q3BSP",
        "RAW",
        "SIB",
        "SMD",
        "STL",
        "TERRAGEN",
        "3D",
        "X",
        "X3D",
        "GLTF",
        "3MF",
        "MMD",
        "STEP"
    }

    for _, importer in ipairs(importers) do
        add_configs("build_" .. importer .. "_importer", {description = "Build " .. importer .. " importers", default = true, type = "boolean"})
    end

    local exporters = {
        "3DS",
        "ASSBIN",
        "ASSXML",
        "COLLADA",
        "OBJ",
        "OPENGEX",
        "PLY",
        "FBX",
        "STL",
        "X",
        "X3D",
        "GLTF",
        "3MF",
        "ASSJSON",
        "STEP"
    }

    for _, exporter in ipairs(exporters) do
        add_configs("build_" .. exporter .. "_exporter", {description = "Build " .. exporter .. " exporters", default = true, type = "boolean"})
    end

    add_deps("cmake")

    on_load(function (package)
        if is_plat("windows", "linux", "macosx") then
            if package:config("build_samples") then
                package:add("deps", "freeglut")
            end
        end
        if is_plat("linux") or package:config("build_zlib") then
            package:add("deps", "zlib")
        end
        if package:config("system_irrxml") then
            package:add("deps", "irrxml")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local config = {}

        local function add_config_arg(config_name, cmake_name)
            table.insert(config, "-D" .. cmake_name .. "=" .. (package:config(config_name) and "ON" or "OFF"))
        end

        add_config_arg("shared",               "BUILD_SHARED_LIBS")
        add_config_arg("double_precision",     "ASSIMP_DOUBLE_PRECISION")
        add_config_arg("opt_build_packages",   "ASSIMP_OPT_BUILD_PACKAGES")
        add_config_arg("no_export",            "ASSIMP_NO_EXPORT")
        add_config_arg("build_zlib",           "ASSIMP_BUILD_ZLIB")
        add_config_arg("build_samples",        "ASSIMP_BUILD_SAMPLES")
        add_config_arg("build_tests",          "ASSIMP_BUILD_TESTS")
        add_config_arg("coveralls",            "ASSIMP_COVERALLS")
        add_config_arg("werror",               "ASSIMP_WERROR")
        add_config_arg("asan",                 "ASSIMP_ASAN")
        add_config_arg("ubsan",                "ASSIMP_UBSAN")
        add_config_arg("system_irrxml",        "SYSTEM_IRRXML")
        add_config_arg("build_docs",           "BUILD_DOCS")
        add_config_arg("ignore_git_hash",      "IGNORE_GIT_HASH")

        --if ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT is set to TRUE, the user can manually disable importers by setting
        --ASSIMP_BUILD_XXX_IMPORTER to FALSE for each importer
        --if ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT is set to FALSE, the user can manually enable importers by setting
        --ASSIMP_BUILD_XXX_IMPORTER to TRUE for each importer
        add_config_arg("build_all_importers",  "ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT")
        for _, importer in ipairs(importers) do
            add_config_arg("build_" .. importer .. "_importer", "ASSIMP_BUILD_" .. importer .. "_IMPORTER")
        end

        --if ASSIMP_BUILD_ALL_EXPORTERS_BY_DEFAULT is set to TRUE, the user can manually disable exporters by setting
        --ASSIMP_BUILD_XXX_EXPORTER to FALSE for each exporter
        --if ASSIMP_BUILD_ALL_EXPORTERS_BY_DEFAULT is set to FALSE, the user can manually enable exporters by setting
        --ASSIMP_BUILD_XXX_EXPORTER to TRUE for each exporter
        add_config_arg("build_all_exporters",  "ASSIMP_BUILD_ALL_EXPORTERS_BY_DEFAULT")
        for _, exporter in ipairs(exporters) do
            add_config_arg("build_" .. exporter .. "_exporter", "ASSIMP_BUILD_" .. exporter .. "_EXPORTER")
        end

        if is_plat("macosx") then
            add_config_arg("build_framework", "BUILD_FRAMEWORK")
        end

        if is_plat("windows") then
            table.insert(config, "-DASSIMP_INSTALL_PDB=" .. ((package:debug() or package:config("install_pdb")) and "ON" or "OFF"))
        end

        if is_plat("linux", "macosx") then
            table.insert(config, "-DINJECT_DEBUG_POSTFIX=" .. ((package:debug() or package:config("inject_debug_postfix")) and "ON" or "OFF"))
        end

        if is_plat("android") then
            add_config_arg("android_jniiosysystem", "ASSIMP_ANDROID_JNIIOSYSTEM")
        end

        if is_plat("windows", "linux", "macosx") then
            add_config_arg("build_assimp_tools", "ASSIMP_BUILD_ASSIMP_TOOLS")
        end

        if is_plat("android", "iphoneos") then
            table.insert(config, "-DASSIMP_BUILD_ASSIMP_TOOLS=OFF")
        end

        import("package.tools.cmake").install(package, config)
        if is_plat("linux") and not package:config("system_irrxml") then
            package:add("links", "assimp", "IrrXML")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aiImportFile", {includes = "assimp/cimport.h"}))
    end)