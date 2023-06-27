package("llvm")

    set_kind("toolchain")
    set_homepage("https://llvm.org/")
    set_description("The LLVM Compiler Infrastructure")

    if is_plat("windows") then
        if is_arch("x86") then
            set_urls("https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win32.zip")
            add_versions("11.0.0", "268043ae0b656cf6272ccb9b8e3f21f51170b74ed8997ddc0b99587983b821ca")
            add_versions("14.0.0", "63afc3c472cb279978c5a7efc25b8783a700aeb416df67886b7057eba52a8742")
            add_versions("15.0.7", "8dbabb2194404220f8641b4b18b24b36eca0ae751380c23fc7743097e205b95f")
        else
            set_urls("https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win64.zip")
            add_versions("11.0.0", "db5b3a44f8f784ebc71f716b54eb63c0d8d21aead12449f36291ab00820271c7")
            add_versions("14.0.0", "c1e1ddf11aa73c58073956d9217086550544328ed5e6ec64c1a709badb231711")
            add_versions("15.0.7", "7d29ca82f8b73e9973209e90428ec9f3fbd3b01925bd26e34f59e959e9ea7eb3")
        end
    elseif is_plat("macosx") then
        if is_arch("x86_64") then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-x86_64-apple-darwin.tar.xz")
            add_versions("11.0.0", "b93886ab0025cbbdbb08b46e5e403a462b0ce034811c929e96ed66c2b07fe63a")
            add_versions("14.0.0", "cf5af0f32d78dcf4413ef6966abbfd5b1445fe80bba57f2ff8a08f77e672b9b3")
        elseif is_arch("arm64") then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-arm64-apple-darwin21.0.tar.xz")
            add_versions("15.0.0", "cfd5c3fa07d7fccea0687f5b4498329a6172b7a15bbc45b547d0ac86bd3452a5")
        end
    elseif is_plat("bsd") then
        if is_arch("x86_64") then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-amd64-unknown-freebsd13.tar.xz")
            add_versions("14.0.0", "b68d73fd57be385e7f06046a87381f7520c8861f492c294e6301d2843d9a1f57")
        elseif is_arch("i386") then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-i386-unknown-freebsd13.tar.xz")
            add_versions("14.0.0", "81f49eb466ce9149335ac8918a5f02fa724d562a94464ed13745db0165b4a220")
        end
    else
        set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz")
        add_versions("11.0.0", "b7b639fc675fa1c86dd6d0bc32267be9eb34451748d2efd03f674b773000e92b")
        add_versions("14.0.0", "35ce9edbc8f774fe07c8f4acdf89ec8ac695c8016c165dd86b8d10e7cba07e23")
        add_versions("15.0.7", "8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6")
        add_versions("16.0.5", "37f540124b9cfd4680666e649f557077f9937c9178489cea285a672e714b2863")
    end

    add_configs("shared",            {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_configs("all",               {description = "Enable all projects.", default = false, type = "boolean"})
    add_configs("bolt",              {description = "Enable bolt project.", default = false, type = "boolean"})
    add_configs("clang",             {description = "Enable clang project.", default = true, type = "boolean"})
    add_configs("clang-tools-extra", {description = "Enable extra clang tools project.", default = false, type = "boolean"})
    add_configs("libclc",            {description = "Enable libclc project.", default = false, type = "boolean"})
    add_configs("lld",               {description = "Enable lld project.", default = false, type = "boolean"})
    add_configs("lldb",              {description = "Enable lldb project.", default = false, type = "boolean"})
    add_configs("polly",             {description = "Enable polly project.", default = false, type = "boolean"})
    add_configs("pstl",              {description = "Enable pstl project.", default = false, type = "boolean"})
    add_configs("mlir",              {description = "Enable mlir project.", default = false, type = "boolean"})
    add_configs("flang",             {description = "Enable flang project.", default = false, type = "boolean"})
    add_configs("compiler-rt",       {description = "Enable compiler-rt project.", default = true, type = "boolean"})

    add_configs("libunwind",         {description = "Enable libunwind runtime.", default = true, type = "boolean"})
    add_configs("libc",              {description = "Enable libc runtime.", default = false, type = "boolean"})
    add_configs("libcxx",            {description = "Enable libcxx runtime.", default = true, type = "boolean"})
    add_configs("libcxxabi",         {description = "Enable libcxxabi runtime.", default = true, type = "boolean"})
    add_configs("openmp",            {description = "Enable openmp runtime.", default = false, type = "boolean"})

    on_load(function (package)
        if package:is_plat("linux") then
            package:add("deps", "cmake")
            package:add("deps", "python 3.x", {kind = "binary", host = true})
            package:add("deps", "zlib", "libffi", {host = true})
            package:add("deps", "binutils", {host = true}) -- needed for gold and strip
        end
        if package:is_plat("linux", "bsd") then
            if package:config("openmp") then
                package:add("deps", "libelf", {host = true})
            end
        end
        -- add components
        if package:is_library() then
            local components = {"mlir", "clang", "libunwind"}
            for _, name in ipairs(components) do
                if package:config(name) or package:config("all") then
                    package:add("components", name, {deps = "base"})
                end
            end
            package:add("components", "base", {default = true})
        end
    end)

    on_fetch("fetch")

    on_install("macosx", "windows", "msys", "bsd", function (package)
        os.cp("*", package:installdir())
    end)

    on_install("linux", function (package)
        local projects = {
            "bolt",
            "clang",
            "clang-tools-extra",
            "libclc",
            "lld",
            "lldb",
            "openmp",
            "polly",
            "pstl",
            "mlir",
            "flang",
            "compiler-rt",
            "openmp"
        }
        local projects_enabled = {}
        if package:config("all") then
            table.insert(projects_enabled, "all")
        else
            for _, project in ipairs(projects) do
                if package:config(project) then
                    table.insert(projects_enabled, project)
                end
            end
        end
        local runtimes = {
            "libc",
            "libunwind",
            "libcxx",
            "libcxxabi"
        }
        local runtimes_enabled = {}
        for _, runtime in ipairs(runtimes) do
            if package:config(runtime) then
                table.insert(runtimes_enabled, runtime)
            end
        end
        local configs = {
            "-DCMAKE_BUILD_TYPE=Release",
            "-DLLVM_ENABLE_PROJECTS=" .. table.concat(projects_enabled, ";"),
            "-DLLVM_ENABLE_RUNTIMES=" .. table.concat(runtimes_enabled, ";"),
            "-DLLVM_POLLY_LINK_INTO_TOOLS=ON",
            "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON",
            "-DLLVM_LINK_LLVM_DYLIB=ON",
            "-DLLVM_ENABLE_EH=ON",
            "-DLLVM_ENABLE_FFI=ON",
            "-DLLVM_ENABLE_RTTI=ON",
            "-DLLVM_INCLUDE_DOCS=OFF",
            "-DLLVM_INCLUDE_TESTS=OFF",
            "-DLLVM_INSTALL_UTILS=ON",
            "-DLLVM_ENABLE_Z3_SOLVER=OFF",
            "-DLLVM_OPTIMIZED_TABLEGEN=ON",
            "-DLLVM_TARGETS_TO_BUILD=all",
            "-DFFI_INCLUDE_DIR=" .. package:dep("libffi"):installdir("include"),
            "-DFFI_LIBRARY_DIR=" .. package:dep("libffi"):installdir("lib"),
            "-DLLDB_USE_SYSTEM_DEBUGSERVER=ON",
            "-DLLDB_ENABLE_PYTHON=OFF",
            "-DLLDB_ENABLE_LUA=OFF",
            "-DLLDB_ENABLE_LZMA=OFF",
            "-DLIBOMP_INSTALL_ALIASES=OFF"
        }
        table.insert(configs, "-DLLVM_CREATE_XCODE_TOOLCHAIN=" .. (package:is_plat("macosx") and "ON" or "OFF")) -- TODO
        table.insert(configs, "-DLLVM_BUILD_LLVM_C_DYLIB=" .. (package:is_plat("macosx") and "ON" or "OFF"))
        if package:has_tool("cxx", "clang", "clangxx") then
            table.insert(configs, "-DLLVM_ENABLE_LIBCXX=ON")
        else
            table.insert(configs, "-DLLVM_ENABLE_LIBCXX=OFF")
            table.insert(configs, "-DCLANG_DEFAULT_CXX_STDLIB=libstdc++")
            -- enable llvm gold plugin for LTO
            table.insert(configs, "-DLLVM_BINUTILS_INCDIR=" .. package:dep("binutils"):installdir("include"))
        end
        os.cd("llvm")
        import("package.tools.cmake").install(package, configs)
    end)

    on_component("mlir",      "components.mlir")
    on_component("clang",     "components.clang")
    on_component("libunwind", "components.libunwind")
    on_component("base",      "components.base")

    on_test(function (package)
        if package:is_toolchain() and not package:is_cross() then
            if not package:is_plat("windows") then
                os.vrun("llvm-config --version")
            end
            if package:config("clang") then
                os.vrun("clang --version")
            end
        end
    end)
