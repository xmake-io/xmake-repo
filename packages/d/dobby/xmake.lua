package("dobby")
    set_description("a lightweight, multi-platform, multi-architecture hook framework.")
    set_license("Apache-2.0")

    add_urls("https://github.com/jmpews/Dobby.git")

    add_versions("2023.4.14", "0932d69c320e786672361ab53825ba8f4245e9d3")
    
    add_patches("2023.4.14", path.join(os.scriptdir(), "patches", "add-link-of-pthread.patch"), "e65f9b428e75db9d1994abf5695102c69a8ae17de36b13ef3d4f33fd6b361fd0")
    add_patches("2023.4.14", path.join(os.scriptdir(), "patches", "fix-compile-on-lower-version-of-gcc.patch"), "632aad7d79e2afd9587089a39c3eb2b64a3750ab3c8954f04672c13abcddbbae")

    -- build
    add_configs("debug",   {description = "Enable debug logging.", default = false, type = "boolean"})
    add_configs("example", {description = "Enable example build.", default = false, type = "boolean"})
    add_configs("test",    {description = "Enable test build.",    default = false, type = "boolean"})

    -- plugins
    add_configs("symbol_resolver",             {description = "Enable symbol resolver plugin.",       default = true,  type = "boolean"})
    add_configs("import_table_replacer",       {description = "Enable import table replacer plugin.", default = false, type = "boolean"})
    add_configs("android_bionic_linker_utils", {description = "Enable android bionic linker utils.",  default = false, type = "boolean"})

    -- features
    add_configs("near_branch",                       {description = "Enable near branch trampoline.",                              default = true,  type = "boolean"})
    add_configs("full_floating_point_register_pack", {description = "Enables saving and packing of all floating-point registers.", default = false, type = "boolean"})

    add_deps("cmake")
    on_install("linux", "macosx", function (package)
        function xmake_option(option)
            return package:config(option) and "ON" or "OFF"
        end
        local configs = {
            "-DDOBBY_DEBUG="                     .. xmake_option("debug"),
            "-DDOBBY_BUILD_EXAMPLE="             .. xmake_option("example"),
            "-DDOBBY_BUILD_TEST="                .. xmake_option("test"),
            "-DPlugin.SymbolResolver="           .. xmake_option("symbol_resolver"),
            "-DPlugin.ImportTableReplace="       .. xmake_option("import_table_replacer"),
            "-DPlugin.Android.BionicLinkerUtil=" .. xmake_option("android_bionic_linker_utils"),
            "-DNearBranch="                      .. xmake_option("near_branch"),
            "-DFullFloatingPointRegisterPack="   .. xmake_option("full_floating_point_register_pack")
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE="       .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:targetarch())
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.trycp("include", package:installdir())
        os.trycp(package:config("shared") and "build/**.so" or "build/**.a", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                DobbyGetVersion();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "dobby.h"}))
    end)
