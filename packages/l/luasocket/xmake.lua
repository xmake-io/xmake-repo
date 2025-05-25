package("luasocket")
    set_homepage("http://lunarmodules.github.io/luasocket/")
    set_description("Network support for the Lua language")
    set_license("MIT")

    add_urls("https://github.com/lunarmodules/luasocket/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lunarmodules/luasocket.git")

    add_versions("v3.1.0", "bf033aeb9e62bcaa8d007df68c119c966418e8c9ef7e4f2d7e96bddeca9cca6e")

    add_deps("lua")

    if is_plat("windows") then
        add_syslinks("ws2_32")
    end

    on_install("windows", function (package)
        import("package.tools.msbuild")
        local lua_dep = package:dep("lua")
        -- Get Lua version
        local lua_ver = lua_dep:version()
        local lua_ver_major_minor = lua_ver:major() .. "." .. lua_ver:minor()
        -- Fetch include/lib dir
        local lua_fetchinfo = lua_dep:fetch()
        local include_paths = {}
        local libfiles = {}
        local linkdir_paths = {}
        for _, includedir in ipairs(lua_fetchinfo.includedirs or lua_fetchinfo.sysincludedirs) do
            table.insert(include_paths, includedir)
        end
        for _, libfile in ipairs(lua_fetchinfo.libfiles) do
            table.insert(libfiles, path.filename(libfile))
        end
        for _, linkdir in ipairs(lua_fetchinfo.linkdirs) do
            table.insert(linkdir_paths, linkdir)
        end
        -- Specify config
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("luasocket.sln", "|x64", "|ARM64", {plain = true})
        end
        local mode = package:is_debug() and "Debug" or "Release"
        local configs = { "luasocket.sln", "/t:mime;socket" }
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        for _, vcxproj in ipairs(os.files("**.vcxproj")) do
            io.replace(vcxproj, "$(LUAINC)", table.concat(include_paths, ";"), {plain = true})
            io.replace(vcxproj, "$(LUALIBNAME)", table.concat(libfiles, ";"), {plain = true})
            io.replace(vcxproj, "$(LUALIB)", table.concat(linkdir_paths, ";"), {plain = true})
            -- Support arm64 builds
            if package:is_arch("arm64") then
                io.replace(vcxproj, "|x64", "|ARM64", {plain = true})
                io.replace(vcxproj, "<Platform>x64", "<Platform>ARM64", {plain = true})
                io.replace(vcxproj, "<RandomizedBaseAddress>false</RandomizedBaseAddress>", "", {plain = true})
            end
            -- Switch vs_runtime MD / MDd -> MT / MTd
            if package:has_runtime("MT", "MTd") then
                io.replace(vcxproj, "MultiThreadedDebugDLL", "MultiThreadedDebug", {plain = true})
                io.replace(vcxproj, "MultiThreadedDLL", "MultiThreaded", {plain = true})
            end
            -- Support static lib builds
            if not package:config("shared") then
                io.replace(vcxproj, "DynamicLibrary", "StaticLibrary", {plain = true})
                io.replace(vcxproj, "LUASOCKET_API=__declspec(dllexport)", "", {plain = true})
                io.replace(vcxproj, "MIME_API=__declspec(dllexport)", "", {plain = true})
            end
        end
        msbuild.build(package, configs)
        os.cp("**.h", package:installdir("include"))
        if package:is_arch("x64", "arm64") then
            os.cp("*/*/socket/core.lib", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "socket", "core.lib"))
            os.cp("*/*/mime/core.lib", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "mime", "core.lib"))
            if package:config("shared") then
                os.cp("*/*/socket/core.dll", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "socket", "core.dll"))
                os.cp("*/*/mime/core.dll", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "mime", "core.dll"))
            end
            os.trycp("*/*/socket/**.pdb", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "socket", "core.pdb"))
            os.trycp("*/*/mime/**.pdb", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "mime", "core.pdb"))
        else
            os.cp("*/socket/core.lib", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "socket", "core.lib"))
            os.cp("*/mime/core.lib", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "mime", "core.lib"))
            if package:config("shared") then
                os.cp("*/socket/core.dll", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "socket", "core.dll"))
                os.cp("*/mime/core.dll", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "mime", "core.dll"))
            end
            os.trycp("*/socket/**.pdb", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "socket"))
            os.trycp("*/mime/**.pdb", path.join(package:installdir("lib"), "lua", lua_ver_major_minor, "mime"))
        end
        package:add("linkdirs", path.join("lib", "lua", lua_ver_major_minor, "socket"))
        package:add("linkdirs", path.join("lib", "lua", lua_ver_major_minor, "mime"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("luaopen_socket_core", {includes = "luasocket.h"}))
    end)
