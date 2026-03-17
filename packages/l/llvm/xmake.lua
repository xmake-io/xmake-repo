package("llvm")
    set_kind("toolchain")
    set_homepage("https://llvm.org/")
    set_description("The LLVM Compiler Infrastructure")
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

    add_configs("compiler-rt",       {description = "Enable compiler-rt runtime.", default = true, type = "boolean"})
    add_configs("libunwind",         {description = "Enable libunwind runtime.", default = true, type = "boolean"})
    add_configs("libc",              {description = "Enable libc runtime.", default = false, type = "boolean"})
    add_configs("libcxx",            {description = "Enable libcxx runtime.", default = true, type = "boolean"})
    add_configs("libcxxabi",         {description = "Enable libcxxabi runtime.", default = true, type = "boolean"})
    add_configs("openmp",            {description = "Enable openmp runtime.", default = false, type = "boolean"})

    if on_source then
        on_source(function (package)
            local precompiled = false
            if package:is_plat("windows") then
                if package:is_arch("x86") then
                    package:set("urls", "https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win32.zip")
                    package:add("versions", "11.0.0", "268043ae0b656cf6272ccb9b8e3f21f51170b74ed8997ddc0b99587983b821ca")
                    package:add("versions", "14.0.0", "63afc3c472cb279978c5a7efc25b8783a700aeb416df67886b7057eba52a8742")
                    package:add("versions", "15.0.7", "8dbabb2194404220f8641b4b18b24b36eca0ae751380c23fc7743097e205b95f")
                    package:add("versions", "16.0.6", "5e1f560f75e7a4c7a6509cf7d9a28b4543e7afcb4bcf4f747e9f208f0efa6818")
                    package:add("versions", "17.0.6", "ce78b510603cb3b347788d2f52978e971cf5f55559151ca13a73fd400ad80c41")
                    package:add("versions", "18.1.1", "1e21b088b1f86aebb4a2e4ad473d1892dccab53ecbe06947f31c6fa56a078bf5")
                    package:add("versions", "21.1.0", "36b9a55e237b2db404aa621aacb8538b56dabc6f49b8927dc1109e8123524d5f")
                    precompiled = true
                else
                    package:set("urls", "https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win64.zip")
                    package:add("versions", "11.0.0", "db5b3a44f8f784ebc71f716b54eb63c0d8d21aead12449f36291ab00820271c7")
                    package:add("versions", "14.0.0", "c1e1ddf11aa73c58073956d9217086550544328ed5e6ec64c1a709badb231711")
                    package:add("versions", "15.0.7", "7d29ca82f8b73e9973209e90428ec9f3fbd3b01925bd26e34f59e959e9ea7eb3")
                    package:add("versions", "16.0.6", "7adb1a630b6cc676a4b983aca9b01e67f770556c6e960e9ee9aa7752c8beb8a3")
                    package:add("versions", "17.0.6", "c480a4c280234b91f7796a1b73b18134ae62fe7c88d2d0c33312d33cb2999187")
                    package:add("versions", "18.1.1", "7040c7a02529bc0c683896d4f851138b700d8aa8f40c5f48503b10f4cc2dc180")
                    package:add("versions", "21.1.0", "130d0067de849be36c0ec84c6d515bd310cab324a4cc95d8cc71a1d3c6c730f4")
                    precompiled = true
                end
            end
            if not precompiled then
                package:set("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz")
                package:add("versions", "11.0.0", "b7b639fc675fa1c86dd6d0bc32267be9eb34451748d2efd03f674b773000e92b")
                package:add("versions", "14.0.0", "35ce9edbc8f774fe07c8f4acdf89ec8ac695c8016c165dd86b8d10e7cba07e23")
                package:add("versions", "15.0.7", "8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6")
                package:add("versions", "16.0.5", "37f540124b9cfd4680666e649f557077f9937c9178489cea285a672e714b2863")
                package:add("versions", "16.0.6", "ce5e71081d17ce9e86d7cbcfa28c4b04b9300f8fb7e78422b1feb6bc52c3028e")
                package:add("versions", "17.0.6", "58a8818c60e6627064f312dbf46c02d9949956558340938b71cf731ad8bc0813")
                package:add("versions", "18.1.1", "8f34c6206be84b186b4b31f47e1b52758fa38348565953fad453d177ef34c0ad")
                package:add("versions", "21.1.0", "1672e3efb4c2affd62dbbe12ea898b28a451416c7d95c1bd0190c26cbe878825")
            end
        end)
    else
        -- After xmake v2.9.5, we'll remove it.
        local precompiled = false
        if is_plat("windows") then
            if is_arch("x86") then
                set_urls("https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win32.zip")
                add_versions("11.0.0", "268043ae0b656cf6272ccb9b8e3f21f51170b74ed8997ddc0b99587983b821ca")
                add_versions("14.0.0", "63afc3c472cb279978c5a7efc25b8783a700aeb416df67886b7057eba52a8742")
                add_versions("15.0.7", "8dbabb2194404220f8641b4b18b24b36eca0ae751380c23fc7743097e205b95f")
                add_versions("16.0.6", "5e1f560f75e7a4c7a6509cf7d9a28b4543e7afcb4bcf4f747e9f208f0efa6818")
                add_versions("17.0.6", "ce78b510603cb3b347788d2f52978e971cf5f55559151ca13a73fd400ad80c41")
                add_versions("18.1.1", "1e21b088b1f86aebb4a2e4ad473d1892dccab53ecbe06947f31c6fa56a078bf5")
                add_versions("21.1.0", "36b9a55e237b2db404aa621aacb8538b56dabc6f49b8927dc1109e8123524d5f")
                precompiled = true
            else
                set_urls("https://github.com/xmake-mirror/llvm-windows/releases/download/$(version)/clang+llvm-$(version)-win64.zip")
                add_versions("11.0.0", "db5b3a44f8f784ebc71f716b54eb63c0d8d21aead12449f36291ab00820271c7")
                add_versions("14.0.0", "c1e1ddf11aa73c58073956d9217086550544328ed5e6ec64c1a709badb231711")
                add_versions("15.0.7", "7d29ca82f8b73e9973209e90428ec9f3fbd3b01925bd26e34f59e959e9ea7eb3")
                add_versions("16.0.6", "7adb1a630b6cc676a4b983aca9b01e67f770556c6e960e9ee9aa7752c8beb8a3")
                add_versions("17.0.6", "c480a4c280234b91f7796a1b73b18134ae62fe7c88d2d0c33312d33cb2999187")
                add_versions("18.1.1", "7040c7a02529bc0c683896d4f851138b700d8aa8f40c5f48503b10f4cc2dc180")
                add_versions("21.1.0", "130d0067de849be36c0ec84c6d515bd310cab324a4cc95d8cc71a1d3c6c730f4")
                precompiled = true
            end
        end
        if not precompiled then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz")
            add_versions("11.0.0", "b7b639fc675fa1c86dd6d0bc32267be9eb34451748d2efd03f674b773000e92b")
            add_versions("14.0.0", "35ce9edbc8f774fe07c8f4acdf89ec8ac695c8016c165dd86b8d10e7cba07e23")
            add_versions("15.0.7", "8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6")
            add_versions("16.0.5", "37f540124b9cfd4680666e649f557077f9937c9178489cea285a672e714b2863")
            add_versions("16.0.6", "ce5e71081d17ce9e86d7cbcfa28c4b04b9300f8fb7e78422b1feb6bc52c3028e")
            add_versions("17.0.6", "58a8818c60e6627064f312dbf46c02d9949956558340938b71cf731ad8bc0813")
            add_versions("18.1.1", "8f34c6206be84b186b4b31f47e1b52758fa38348565953fad453d177ef34c0ad")
            add_versions("21.1.0", "1672e3efb4c2affd62dbbe12ea898b28a451416c7d95c1bd0190c26cbe878825")
        end
    end

    on_load(function (package)
        if not package:is_plat("windows", "msys") then
            package:add("deps", "cmake")
            package:add("deps", "python 3.x", {kind = "binary", host = true})
            package:add("deps", "zlib", "libffi", {host = true})
        end
        if package:is_plat("linux") then
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

    on_install("windows", "msys", function (package)
        os.cp("*", package:installdir())
    end)

    on_install("linux", "macosx", "bsd", function (package)
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
            "compiler-rt",
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
            local binutils = package:dep("binutils")
            if binutils then
                table.insert(configs, "-DLLVM_BINUTILS_INCDIR=" .. binutils:installdir("include"))
            end
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
