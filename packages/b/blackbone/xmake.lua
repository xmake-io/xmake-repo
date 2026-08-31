package("blackbone")
    set_homepage("https://github.com/DarthTon/Blackbone")
    set_description("Windows memory manipulation library with manual PE mapping support.")
    set_license("MIT AND Zlib AND LGPL-3.0-or-later AND GPL-3.0-or-later")

    add_urls("https://github.com/DarthTon/Blackbone.git")
    add_versions("2023.07.17", "5ede6ce50cd8ad34178bfa6cae05768ff6b3859b")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_defines("BLACKBONE_STATIC")
    add_links("BlackBone", "diaguids")
    add_syslinks("advapi32", "user32", "psapi", "shlwapi", "ole32", "oleaut32", "version")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows|x86", "windows|x64", function (package)
        -- WOW64Ext relies on transitive includes removed from recent Windows SDKs.
        io.replace("src/3rd_party/rewolf-wow64ext/src/wow64ext.cpp", "#include <cstddef>",
                   "#include <cstddef>\n#include <cstdlib>\n#include <winternl.h>", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)

        -- Preserve the license notices of the bundled components.
        os.cp("src/3rd_party/AsmJit/LICENSE.md", package:installdir("licenses", "AsmJit.txt"))
        os.cp("src/3rd_party/rewolf-wow64ext/lgpl-3.0.txt", package:installdir("licenses", "WOW64Ext.txt"))
        os.cp("src/BlackBone/Asm/LDasm.c", package:installdir("licenses", "LDasm.c"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                blackbone::Process process;
                process.Attach(GetCurrentProcessId());
                process.modules().GetExport(L"kernel32.dll", "GetCurrentProcessId");
                process.mmap().UnmapAllModules();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "BlackBone/Process/Process.h"}))
    end)
