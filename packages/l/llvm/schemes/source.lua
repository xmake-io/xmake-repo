function add_urls(package, scheme_name)
    if package:is_plat("windows") then
        return
    end
    local scheme = package
    if scheme_name then
        scheme = package:scheme(scheme_name)
    end

    scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz")
    scheme:add("versions", "23.1.4", "819ecf7351f1a66f76b2d701d8942faaf5faeb324cb90c9d5b090de142434bb2")
    scheme:add("versions", "22.1.8", "922f1817a0df7b1489272d18134ee0087a8b068828f87ac63b9861b1a9965888")
    scheme:add("versions", "21.1.8", "4633a23617fa31a3ea51242586ea7fb1da7140e426bd62fc164261fe036aa142")
    scheme:add("versions", "20.1.8", "6898f963c8e938981e6c4a302e83ec5beb4630147c7311183cf61069af16333d")
    scheme:add("versions", "19.1.7", "82401fea7b79d0078043f7598b835284d6650a75b93e64b6f761ea7b63097501")
    scheme:add("versions", "18.1.8", "0b58557a6d32ceee97c8d533a59b9212d87e0fc4d2833924eb6c611247db2f2a")
    scheme:add("versions", "11.0.0", "b7b639fc675fa1c86dd6d0bc32267be9eb34451748d2efd03f674b773000e92b")
    scheme:add("versions", "14.0.0", "35ce9edbc8f774fe07c8f4acdf89ec8ac695c8016c165dd86b8d10e7cba07e23")
    scheme:add("versions", "15.0.7", "8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6")
    scheme:add("versions", "16.0.5", "37f540124b9cfd4680666e649f557077f9937c9178489cea285a672e714b2863")
    scheme:add("versions", "16.0.6", "ce5e71081d17ce9e86d7cbcfa28c4b04b9300f8fb7e78422b1feb6bc52c3028e")
    scheme:add("versions", "17.0.6", "58a8818c60e6627064f312dbf46c02d9949956558340938b71cf731ad8bc0813")
    scheme:add("versions", "18.1.1", "8f34c6206be84b186b4b31f47e1b52758fa38348565953fad453d177ef34c0ad")
    scheme:add("versions", "21.1.0", "1672e3efb4c2affd62dbbe12ea898b28a451416c7d95c1bd0190c26cbe878825")
end

function install(package)
    import("lib.detect.find_tool")
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
    -- LLVM_CREATE_XCODE_TOOLCHAIN requires full Xcode to detect its version,
    -- it fails when only the command line tools are installed
    local xcodebuild = false
    if package:is_plat("macosx") then
        xcodebuild = find_tool("xcodebuild")
    end
    table.insert(configs, "-DLLVM_CREATE_XCODE_TOOLCHAIN=" .. (xcodebuild and "ON" or "OFF"))
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
end
