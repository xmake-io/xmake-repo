import("core.tool.toolchain")
import("core.base.option")

function _get_compiler(package, toolchain)
    local cxx = package:build_getenv("cxx")
    if package:is_plat("macosx") then
        -- we uses ld/clang++ for link stdc++ for shared libraries
        -- and we need `xcrun -sdk macosx clang++` to make b2 to get `-isysroot` automatically
        local cc = package:build_getenv("ld")
        if cc and cc:find("clang", 1, true) and cc:find("Xcode", 1, true) then
            cc = "xcrun -sdk macosx clang++"
        end
        return format("using darwin : : %s ;", cc)
    elseif package:is_plat("windows") then
        local vs_toolset = toolchain:config("vs_toolset")
        local msvc_ver = ""
        local win_toolset = "msvc"
        if toolchain:name() == "clang-cl" then
            win_toolset = "clang-win"
            cxx = cxx:gsub("(clang%-cl)$", "%1.exe", 1)
            msvc_ver = ""
        elseif vs_toolset then
            local i = vs_toolset:find("%.")
            msvc_ver = i and vs_toolset:sub(1, i + 1)
        end

        -- Specifying a version will disable b2 from forcing tools
        -- from the latest installed msvc version.
        return format("using %s : %s : \"%s\" ;", win_toolset, msvc_ver, cxx:gsub("\\", "\\\\"))
    else
        cxx = cxx:gsub("gcc$", "g++")
        cxx = cxx:gsub("gcc%-", "g++-")
        cxx = cxx:gsub("clang$", "clang++")
        cxx = cxx:gsub("clang%-", "clang++-")
        if cxx and cxx:find("clang", 1, true) then
            return format("using clang : : \"%s\" ;", cxx:gsub("\\", "/"))
        else
            return format("using gcc : : \"%s\" ;", cxx:gsub("\\", "/"))
        end
    end
end

function _config_deppath(package, file, depname, rule)
    local dep = package:dep(depname)
    local info = dep:fetch({external = false})
    if info then
        local includedirs = table.wrap(info.sysincludedirs or info.includedirs)
        for i, dir in ipairs(includedirs) do
            includedirs[i] = path.unix(dir)
        end
        local linkdirs = table.wrap(info.linkdirs)
        for i, dir in ipairs(linkdirs) do
            linkdirs[i] = path.unix(dir)
        end
        local links = table.wrap(info.links)
        local usingstr = format("\nusing %s : %s : <include>%s <search>%s <name>%s ;",
            rule, dep:version(),
            table.concat(includedirs, ";"),
            table.concat(linkdirs, ";"),
            table.concat(links, ";"))
        file:write(usingstr)
    end
end

function main(package)
    import("libs", {rootdir = package:scriptdir()})

    -- get host toolchain
    local host_toolchain
    if package:is_plat("windows") then
        host_toolchain = toolchain.load("msvc", {plat = "windows", arch = os.arch()})
        if not host_toolchain:check() then
            host_toolchain = toolchain.load("clang-cl", {plat = "windows", arch = os.arch()})
        end
        assert(host_toolchain:check(), "host msvc or clang-cl not found!")
    end

    -- force boost to compile with the desired compiler
    local file = io.open("user-config.jam", "w")
    if file then
        file:write(_get_compiler(package, host_toolchain))
        file:close()
    end

    local bootstrap_argv =
    {
        "--prefix=" .. package:installdir(),
        "--libdir=" .. package:installdir("lib"),
        "--without-icu"
    }

    if package:has_tool("cxx", "clang", "clangxx") then
        table.insert(bootstrap_argv, "--with-toolset=clang")
    end

    if package:is_plat("windows") then
        -- for bootstrap.bat, all other arguments are useless
        bootstrap_argv = { "msvc" }
        os.vrunv("bootstrap.bat", bootstrap_argv, {envs = host_toolchain:runenvs()})
    elseif package:is_plat("mingw") and is_host("windows") then
        bootstrap_argv = { "gcc" }
        os.vrunv("bootstrap.bat", bootstrap_argv)
        -- todo looking for better solution to fix the confict between user-config.jam and project-config.jam
        io.replace("project-config.jam", "using[^\n]+", "")
    else
        os.vrunv("./bootstrap.sh", bootstrap_argv)
    end

    -- get build toolchain
    local build_toolchain
    local build_toolset
    local runenvs
    if package:is_plat("windows") then
        if package:has_tool("cxx", "clang_cl") then
            build_toolset = "clang-win"
            build_toolchain = package:toolchain("clang-cl")
        elseif package:has_tool("cxx", "clang") then
            build_toolset = "clang-win"
            build_toolchain = package:toolchain("clang") or package:toolchain("llvm")
        elseif package:has_tool("cxx", "cl") then
            build_toolset = "msvc"
            build_toolchain = package:toolchain("msvc")
        end
        if build_toolchain then
            runenvs = build_toolchain:runenvs()
        end
    end

    local file = io.open("user-config.jam", "w")
    if file then
        file:write(_get_compiler(package, build_toolchain))
        if package:config("lzma") then
            _config_deppath(package, file, "xz", "lzma")
        end
        if package:config("zstd") then
            _config_deppath(package, file, "zstd", "zstd")
        end
        if package:config("zlib") then
            _config_deppath(package, file, "zlib", "zlib")
        end
        if package:config("bzip2") then
            _config_deppath(package, file, "bzip2", "bzip2")
        end
        file:close()
    end
    os.vrun("./b2 headers")

    local njobs = option.get("jobs") or tostring(os.default_njob())
    local argv =
    {
        "--prefix=" .. package:installdir(),
        "--libdir=" .. package:installdir("lib"),
        "-d2",
        "-j" .. njobs,
        "--hash",
        "-q", -- quit on first error
        "--layout=tagged-1.66", -- prevent -x64 suffix in case cmake can't find it
        "--user-config=user-config.jam",
        "install",
        "threading=" .. (package:config("multi") and "multi" or "single"),
        "debug-symbols=" .. (package:debug() and "on" or "off"),
        "link=" .. (package:config("shared") and "shared" or "static"),
        "variant=" .. (package:is_debug() and "debug" or "release"),
        "runtime-debugging=" .. (package:is_debug() and "on" or "off")
    }

    local cxxflags = {}
    if package:config("lzma") then
        if package:is_plat("windows") and not package:dep("xz"):config("shared") then
            table.insert(cxxflags, "-DLZMA_API_STATIC")
        end
    else
        table.insert(argv, "-sNO_LZMA=1")
    end
    if not package:config("zstd") then
        table.insert(argv, "-sNO_ZSTD=1")
    end
    if not package:config("zlib") then
        table.insert(argv, "-sNO_ZLIB=1")
    end
    if not package:config("bzip2") then
        table.insert(argv, "-sNO_BZIP2=1")
    end

    if package:config("lto") then
        table.insert(argv, "lto=on")
    end
    if package:is_arch("aarch64", "arm+.*") then
        table.insert(argv, "architecture=arm")
    end
    if package:is_arch(".+64.*") then
        table.insert(argv, "address-model=64")
    else
        table.insert(argv, "address-model=32")
    end

    local linkflags = {}
    table.join2(cxxflags, table.wrap(package:config("cxflags")))
    table.join2(cxxflags, table.wrap(package:config("cxxflags")))
    if package:is_plat("windows") then
        if package:config("shared") then
            table.insert(argv, "runtime-link=shared")
        elseif package:has_runtime("MT", "MTd") then
            table.insert(argv, "runtime-link=static")
        else
            table.insert(argv, "runtime-link=shared")
        end
        table.insert(argv, "toolset=" .. build_toolset)
        table.insert(cxxflags, "-std:c++14")
    elseif package:is_plat("mingw") then
        table.insert(argv, "toolset=gcc")
    elseif package:is_plat("macosx") then
        table.insert(argv, "toolset=darwin")

        -- fix macosx arm64 build issue https://github.com/microsoft/vcpkg/pull/18529
        table.insert(cxxflags, "-std=c++14")
        table.insert(cxxflags, "-arch")
        table.insert(cxxflags, package:arch())
        local xcode = package:toolchain("xcode") or import("core.tool.toolchain").load("xcode", {plat = package:plat(), arch = package:arch()})
        if xcode:check() then
            local xcode_dir = xcode:config("xcode")
            local xcode_sdkver = xcode:config("xcode_sdkver")
            local target_minver = xcode:config("target_minver")
            if xcode_dir and xcode_sdkver then
                local xcode_sdkdir = xcode_dir .. "/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX" .. xcode_sdkver .. ".sdk"
                table.insert(cxxflags, "-isysroot")
                table.insert(cxxflags, xcode_sdkdir)
            end
            if target_minver then
                table.insert(cxxflags, "-mmacosx-version-min=" .. target_minver)
            end
        end
    else
        table.insert(cxxflags, "-std=c++14")
        if package:config("pic") ~= false then
            table.insert(cxxflags, "-fPIC")
        end
    end
    if package.has_runtime and package:has_runtime("c++_shared", "c++_static") then
        table.insert(cxxflags, "-stdlib=libc++")
        table.insert(linkflags, "-stdlib=libc++")
        if package:has_runtime("c++_static") then
            table.insert(linkflags, "-static-libstdc++")
        end
    end
    if package:config("asan") then
        table.insert(cxxflags, "-fsanitize=address")
        table.insert(linkflags, "-fsanitize=address")
    end
    if cxxflags then
        table.insert(argv, "cxxflags=" .. table.concat(cxxflags, " "))
    end
    if linkflags then
        table.insert(argv, "linkflags=" .. table.concat(linkflags, " "))
    end
    libs.for_each(function (libname)
        if package:config("all") or package:config(libname) then
            table.insert(argv, "--with-" .. libname)
        end
    end)

    if package:is_plat("linux") then
        table.insert(argv, "pch=off")
    end
    local ok = os.execv("./b2", argv, {envs = runenvs, try = true, stdout = "boost-log.txt"})
    if ok ~= 0 then
        raise("boost build failed, please check log in " .. path.join(os.curdir(), "boost-log.txt"))
    end
end
