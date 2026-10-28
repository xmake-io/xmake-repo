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

    add_schemes("binary", "source")

    on_source(function (package)
        import("schemes.binary")
        import("schemes.source")
        binary.add_urls(package, "binary")
        source.add_urls(package, "source")
    end)

    on_load(function (package)
        if package:current_scheme():name() == "source" then
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

    on_install("@windows", "@msys", "@linux", "@macosx", "@bsd", function (package)
        import("schemes.binary")
        import("schemes.source")
        if package:current_scheme():name() == "binary" then
            binary.install(package)
        else
            source.install(package)
        end
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
