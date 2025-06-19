package("libllvm")
    set_kind("library")
    set_homepage("https://llvm.org/")
    set_description("The LLVM Compiler Infrastructure.")

    add_configs("exception", {description = "Enable C++ exception support for LLVM.", default = true, type = "boolean"})
    add_configs("rtti",      {description = "Enable C++ RTTI support for LLVM.", default = true, type = "boolean"})

    add_configs("ms_dia",  {description = "Enable DIA SDK to support non-native PDB parsing. (msvc only)", default = true, type = "boolean"})
    add_configs("libffi",  {description = "Enable libffi to support the LLVM interpreter to call external functions.", default = false, type = "boolean"})
    add_configs("httplib", {description = "Enable cpp-httplib to support llvm-debuginfod serve debug information over HTTP.", default = false, type = "boolean"})
    add_configs("libcxx",  {description = "Use libc++ as C++ standard library instead of libstdc++", default = false, type = "boolean"})

    includes(path.join(os.scriptdir(), "constants.lua"))
    for _, project in ipairs(get_llvm_known_projects()) do
        add_configs(project:gsub("-", "_"), {description = "Build " .. project .. " project.", default = (project == "clang"), type = "boolean"})
    end
    for _, runtime in ipairs(get_llvm_all_runtimes()) do
        add_configs(runtime:gsub("-", "_"), {description = "Build " .. runtime .. " runtime.", default = false, type = "boolean"})
    end

    if is_plat("windows") then
        -- pre-built
        if is_arch("x64") then
            add_urls("https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win64.zip")
            add_versions("19.1.7", "c6e058c6012f499811caa1ec037cc1b5c2fd2f8c20cc3315cae602cbd6c81a5e")
        end

        -- The LLVM shared library cannot be built under windows.
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

        add_configs("runtimes",   {description = "Set vs compiler runtime.", default = "MT", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT", readonly = true})
        add_syslinks("psapi", "shell32", "ole32", "uuid", "advapi32", "ws2_32", "ntdll", "version")
    else
        -- self-built
        add_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz", {alias = "tarball"})
        add_urls("https://github.com/llvm/llvm-project.git", {alias = "git"})
        add_versions("tarball:19.1.7", "82401fea7b79d0078043f7598b835284d6650a75b93e64b6f761ea7b63097501")
        add_versions("git:19.1.7", "llvmorg-19.1.7")

        add_deps("ninja")
        add_deps("zlib", "zstd", {optional = true})
        set_policy("package.cmake_generator.ninja", true)
    end

    -- workaround to fix "error: undefined symbol: __mulodi4" (armeabi-v7a, r22, windows)
    if is_plat("android") then
        add_syslinks("compiler_rt-extras")
    end

    -- error: undefined symbol: backtrace
    if is_plat("bsd") then
        add_syslinks("execinfo")
    end

    add_deps("cmake")
    on_load(function (package)
        local constants = import('constants')
        
        -- add deps.
        if not package:is_plat("windows") then -- not prebuilt
            package:add("deps", "python 3.x", {kind = "binary", host = true})
            if package:config("libffi") then
                package:add("deps", "libffi")
            end
            if package:config("httplib") then
                package:add("deps", "cpp-httplib")
            end
            if package:config("libcxx") then
                package:add("deps", "libc++")
            end
        end

        if package:is_plat("windows") and package:config("ms_dia") then
            package:add("deps", "diasdk")
        end

        -- add links
        local linkable_projects = {"lldb", "lld", "clang", "polly", "bolt"}
        table.insert(linkable_projects, "llvm") -- make sure that the base library is last.
        for _, name in ipairs(linkable_projects) do
            local cname = name:gsub("-", "_")
            local ptype = package:config("shared") and "shared" or "static"
            if cname == "llvm" or package:config(cname) then
                package:add("links", constants[("get_%s_%s_libraries"):format(cname, ptype)]())
            end
        end
        if package:is_plat("windows") then
            package:add("links", "LLVM-C")
        end

    end)

    on_install("windows|x64", function (package)
        os.cp("*", package:installdir())
    end)

    on_install("linux", "macosx", "bsd", "android", "iphoneos", "cross", function (package)
        local constants = import('constants')

        local projects_enabled = {}
        local runtimes_enabled = {}
        for _, project in ipairs(constants.get_llvm_known_projects()) do
            if package:config(project:gsub("-", "_")) then
                table.insert(projects_enabled, project)
            end
        end
        for _, runtime in ipairs(constants.get_llvm_all_runtimes()) do
            if package:config(runtime:gsub("-", "_")) then
                table.insert(runtimes_enabled, runtime)
            end
        end

        local configs = {
            "-DBUILD_SHARED_LIBS=OFF",

            -- llvm
            "-DLLVM_BUILD_UTILS=OFF",
            "-DLLVM_INCLUDE_DOCS=OFF",
            "-DLLVM_INCLUDE_EXAMPLES=OFF",
            "-DLLVM_INCLUDE_TESTS=OFF",
            "-DLLVM_INCLUDE_BENCHMARKS=OFF",
            "-DLLVM_OPTIMIZED_TABLEGEN=ON",
            "-DLLVM_ENABLE_PROJECTS=" .. table.concat(projects_enabled, ";"),
            "-DLLVM_ENABLE_RUNTIMES=" .. table.concat(runtimes_enabled, ";"),

            -- disable tools build - to save link time
            "-DLLVM_BUILD_TOOLS=OFF",
            "-DCLANG_BUILD_TOOLS=OFF",
            "-DCLANG_ENABLE_CLANGD=OFF",
            "-DBOLT_BUILD_TOOLS=OFF",
            "-DFLANG_BUILD_TOOLS=OFF",
            "-DLLD_BUILD_TOOLS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLLVM_BUILD_LLVM_DYLIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_EH=" .. (package:config("exception") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_DIA_SDK=" .. (package:config("ms_dia") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_LIBCXX=" .. (package:config("libcxx") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_ZSTD=" .. (package:dep("zstd") and "ON" or "OFF"))
        table.insert(configs, "-DLLVM_ENABLE_ZLIB=" .. (package:dep("zlib") and "ON" or "OFF"))
        if package:config("libffi") then
            table.insert(configs, "-DLLVM_ENABLE_FFI=ON")
            table.insert(configs, "-DFFI_INCLUDE_DIR=" .. package:dep("libffi"):installdir("include"))
            table.insert(configs, "-DFFI_LIBRARY_DIR=" .. package:dep("libffi"):installdir("lib"))
        else
            table.insert(configs, "-DLLVM_ENABLE_FFI=OFF")
        end
        if package:config("httplib") then
            table.insert(configs, "-DLLVM_ENABLE_HTTPLIB=ON")
            table.insert(configs, "-Dhttplib_ROOT=" .. package:dep("cpp-httplib"):installdir())
        else
            table.insert(configs, "-DLLVM_ENABLE_HTTPLIB=OFF")
        end

        for tooldir in string.gmatch(io.readfile("clang/tools/CMakeLists.txt"), "add_clang_subdirectory%((.-)%)") do
            if tooldir ~= "libclang" and (tooldir ~= "clang-shlib" or not package:config("shared")) then
                local tool = tooldir:upper():gsub("-", "_")
                table.insert(configs, "-DCLANG_TOOL_" .. tool .. "_BUILD=OFF")
            end
        end

        if package:is_plat("android") then
            local triple
            if package:is_arch("arm64-v8a") then
                triple = "aarch64-linux-android"
            elseif package:arch():startswith("armeabi") then
                triple = "armv7a-linux-androideabi"
            elseif package:is_arch("x86") then
                triple = "i686-linux-android"
            elseif package:is_arch("x86_64") then
                triple = "x86_64-linux-android"
            else
                raise("unsupported arch(%s) for android!", package:arch())
            end
            table.insert(configs, "-DLLVM_HOST_TRIPLE=" .. triple)
        end
        if package:is_plat("iphoneos") then
            local triple
            if package:is_arch("arm64") then
                triple = "aarch64-apple-ios"
            else
                raise("unsupported arch(%s) for iphoneos!", package:arch())
            end
            table.insert(configs, "-DLLVM_HOST_TRIPLE=" .. triple)

            -- LLVM build systems mostly use "Darwin", not if(APPLE)
            table.insert(configs, "-DCMAKE_SYSTEM_NAME=Darwin")
        end

        function tryadd_dep(depname, varname)
            varname = varname or depname
            local dep = package:dep(depname)
            if dep and not dep:is_system() then
                local fetchinfo = dep:fetch({external = false})
                if fetchinfo then
                    local includedirs = fetchinfo.includedirs or fetchinfo.sysincludedirs
                    if includedirs and #includedirs > 0 then
                        table.insert(configs, "-D" .. varname .. "_INCLUDE_DIR=" .. table.concat(includedirs, " "):gsub("\\", "/"))
                    end
                    local libfiles = fetchinfo.libfiles
                    if libfiles then
                        table.insert(configs, "-D" .. varname .. "_LIBRARY=" .. table.concat(libfiles, " "):gsub("\\", "/"))
                    end
                end
            end
        end
        tryadd_dep("zlib", "ZLIB")
        tryadd_dep("zstd")

        os.cd("llvm")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <llvm/IR/LLVMContext.h>
            #include <llvm/IR/Module.h>
            void test() {
                llvm::LLVMContext context;
                llvm::Module module("test", context);
            }
        ]]}, {configs = {languages = 'c++17'}}))
        if package:config("clang") then
            assert(package:check_cxxsnippets({test = [[
                #include <clang/Frontend/CompilerInstance.h>
                void test() {
                    clang::CompilerInstance instance;
                }
            ]]}, {configs = {languages = 'c++17'}}))
        end
    end)
