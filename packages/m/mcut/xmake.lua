package("mcut")
    set_homepage("https://cutdigital.github.io/mcut.site/")
    set_description("Fast & robust mesh boolean library in C++")
    set_license("GPL-3.0")

    add_urls("https://github.com/cutdigital/mcut/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cutdigital/mcut.git")

    add_versions("v1.2.0", "dd339f222468a09f9b54f81ad7f21ef9b5b0b306953615d55684ba581d757297")
    add_versions("v1.1.0", "a31efbb4c963a40574ee0bad946d02dc77df873f68d35524363bd71d2ae858bd")

    add_patches("1.2.0", path.join(os.scriptdir(), "patches", "1.2.0", "install.patch"), "f5eecb8fa8281c11ab8a10314b83bfba437009255fb46382d210010f584dabec")
    add_patches("1.1.0", path.join(os.scriptdir(), "patches", "1.1.0", "install.patch"), "438f5b76d8ad58253420844248c5da09404cc7ad4a7a19c174e90aacf714d0f0")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install("windows|x86", "windows|x64", "macosx", "linux", "mingw", function (package)
        -- patch gcc 13
        io.replace("include/mcut/internal/hmesh.h", "#include <vector>", "#include <vector>\n#include <cstdint>\n", {plain = true})

        local cxflags = {}
        if package:is_plat("mingw") then
            io.replace("include/mcut/internal/tpool.h", "_Acquires_lock_(return)", "", {plain = true})
            cxflags = "-Wa,-mbig-obj"
        elseif package:is_plat("windows") and package:config("shared") then
            package:add("defines", "MCUT_SHARED_LIB")
        end

        local configs = {"-DMCUT_BUILD_TESTS=OFF", "-DMCUT_BUILD_TUTORIALS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPES=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMCUT_BUILD_AS_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                McContext context = MC_NULL_HANDLE;
                mcCreateContext(&context, MC_NULL_HANDLE);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "mcut/mcut.h"}))
    end)
