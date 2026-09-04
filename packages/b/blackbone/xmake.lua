package("blackbone")
    set_homepage("https://github.com/DarthTon/Blackbone")
    set_description("Windows memory manipulation library with manual PE mapping support.")
    set_license("MIT AND GPL-3.0-or-later")

    add_urls("https://github.com/DarthTon/Blackbone.git")
    add_versions("2023.07.17", "5ede6ce50cd8ad34178bfa6cae05768ff6b3859b")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_defines("BLACKBONE_STATIC")
    add_links("BlackBone")
    add_syslinks("advapi32", "user32", "psapi", "shlwapi", "ole32", "oleaut32", "version")

    add_deps("asmjit 2014.12.01", "beaengine", {configs = {shared = false}})
    if is_arch("x86") then
        add_deps("rewolf-wow64ext 2022.09.26", {configs = {shared = false}})
    end
    add_deps("diasdk", {system = true})

    on_check(function (package)
        assert(not package:is_arch("arm.*"), "package(blackbone): does not support arm.")
    end)

    on_install("windows|x86", "windows|x64", function (package)
        -- VersionApi.h implements Blackbone's own version helpers, not a dependency.
        os.cp("src/3rd_party/VersionApi.h", "src/BlackBone/Include/VersionApi.h")
        for _, file in ipairs(os.files("src/BlackBone/**|**.vcxproj*|**.filters")) do
            if table.contains({".cpp", ".h", ".hpp"}, path.extension(file)) then
                io.replace(file, "<3rd_party/VersionApi.h>", "<BlackBone/Include/VersionApi.h>", {plain = true})
                io.replace(file, '"../../3rd_party/AsmJit/AsmJit.h"', "<asmjit/asmjit.h>", {plain = true})
                io.replace(file, "<3rd_party/DIA/dia2.h>", "<dia2.h>", {plain = true})
                io.replace(file, "<3rd_party/BeaEngine/headers/BeaEngine.h>", "<beaengine/BeaEngine.h>", {plain = true})
                io.replace(file, "<3rd_party/rewolf-wow64ext/src/wow64ext.h>", "<wow64ext.h>", {plain = true})
            end
        end
        io.replace("src/BlackBone/Subsystem/Wow64Subsystem.cpp", "getNTDLL64()", 'GetModuleHandle64(L"ntdll.dll")', {plain = true})
        -- Native x64 processes never use the WOW64-only subsystem.
        io.replace("src/BlackBone/Process/ProcessCore.cpp", "if (wowSrc == TRUE)", "#ifdef USE32\n        if (wowSrc == TRUE)", {plain = true})
        io.replace("src/BlackBone/Process/ProcessCore.cpp", "else\n            _native = std::make_unique<Native>",
                   "else\n#endif\n            _native = std::make_unique<Native>", {plain = true})
        os.rm("src/3rd_party")
        os.rm("DIA")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
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
