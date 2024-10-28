package("libunifex")
    set_homepage("https://github.com/facebookexperimental/libunifex")
    set_description("The 'libunifex' project is a prototype implementation of the C++ sender/receiver async programming model that is currently being considered for standardisation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebookexperimental/libunifex/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebookexperimental/libunifex.git")

    add_versions("v0.4.0", "d5ce3b616e166da31e6b4284764a1feeba52aade868bcbffa94cfd86b402716e")

    add_patches("v0.4.0", "patches/v0.4.0/std-memset.patch", "8108bf13b8071cff16e6d96bf97399ed3e657f59d6a843a078e42e4b3318def4")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                if vs_toolset then
                    local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                    local minor = vs_toolset_ver:minor()
                    assert(minor and minor >= 30, "package(libunifex) require vs_toolset >= 14.3")
                end
            end
            assert(package:has_cxxincludes("coroutine", {configs = {languages = "c++20"}}), "package(libunifex) require C++20 with coroutine support")
        end)
    end

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DUNIFEX_BUILD_EXAMPLES=OFF", "-DCMAKE_CXX_STANDARD=20"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "source/**.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace unifex;
            using namespace std::chrono;
            auto delay(milliseconds ms) {
                return schedule_after(current_scheduler, ms);
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"chrono", "unifex/on.hpp", "unifex/scheduler_concepts.hpp"}}))
    end)
