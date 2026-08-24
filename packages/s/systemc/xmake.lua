package("systemc")
    set_homepage("https://accellera.org")
    set_description("SystemC: A modeling language for system-level design")
    set_license("Apache-2.0")

    add_urls("https://github.com/accellera-official/systemc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/accellera-official/systemc.git")

    add_versions("3.0.1", "5b191bb6500712243eb152e155c1c6039066cf38")

    add_deps("cmake")

    add_configs("shared",    {description = "Build shared library", type = "boolean"})
    add_configs("pthreads",  {description = "Use POSIX threads",    type = "boolean", default = false})
    add_configs("assertions",{description = "Enable assertions",    type = "boolean", default = true})
    add_configs("docs",      {description = "Build source documentation", type = "boolean", default = false})

    on_check(function(package)
        local supported = {"linux", "macosx", "windows", "mingw", "cygwin", "bsd"}
        if not table.contains(supported, package:plat()) then
            raise("systemc: unsupported platform '%s' (supported: %s)",
                  package:plat(), table.concat(supported, ", "))
        end
    end)

    on_load(function(package)
        if package:config("shared") == nil then
            local default_shared = not package:is_plat("windows")
            package:set_config("shared", default_shared)
        end
    end)

    on_install(function(package)
        import("package.tools.cmake")

        -- 设置临时目录
        local tmpdir = os.tmpdir()
        os.setenv("TMPDIR", tmpdir)
        os.setenv("TEMP", tmpdir)

        -- 构建目录
        local builddir = package:builddir()
        os.mkdir(builddir)

        -- 源码目录：xmake 会将源码 clone 到 builddir/source/ 下
        local sourcedir = builddir .. "/source/systemc"

        -- Windows 源码修补：在配置之前替换 osfx/opfx
        if package:is_plat("windows") then
            local src_file = sourcedir .. "/src/sysc/datatypes/int/sc_int64_io.cpp"
            if os.exists(src_file) then
                local content = io.readfile(src_file)
                content = content:gsub("([%w_]+)%.osfx%(", "%1.flush()")
                content = content:gsub("([%w_]+)%.opfx%(", "%1.good()")
                io.writefile(src_file, content)
            end
        end

        -- 生成器选择
        local generator = "Unix Makefiles"
        if package:is_plat("windows") or package:is_plat("mingw") then
            generator = "Ninja"
        end

        -- CMake 参数
        local configs = {
            "-G", generator,
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DENABLE_PTHREADS=" .. (package:config("pthreads") and "ON" or "OFF"),
            "-DENABLE_ASSERTIONS=" .. (package:config("assertions") and "ON" or "OFF"),
            "-DBUILD_SOURCE_DOCUMENTATION=" .. (package:config("docs") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DCMAKE_INSTALL_PREFIX=" .. package:installdir(),
            "-DCMAKE_CXX_STANDARD=17",
            "-DCMAKE_CXX_STANDARD_REQUIRED=ON",
            "-DCMAKE_CXX_EXTENSIONS=OFF",
        }

        -- macOS 禁用 sanitizer
        if package:is_plat("macosx") then
            table.insert(configs, "-DCMAKE_CXX_FLAGS=-fno-sanitize=address -fno-sanitize=undefined")
            table.insert(configs, "-DCMAKE_C_FLAGS=-fno-sanitize=address -fno-sanitize=undefined")
        end

        -- 1. CMake 配置
        cmake.configure(package, {configs = configs, buildir = builddir, sourcedir = sourcedir})

        -- 2. 构建
        cmake.build(package, {buildir = builddir})

        -- 3. 安装
        cmake.install(package, {buildir = builddir})
    end)

    on_test(function(package)
        local snippet = [[
            #include <systemc.h>
            int sc_main(int argc, char* argv[]) {
                sc_core::sc_clock clk("clk", 1, sc_core::SC_NS);
                return 0;
            }
        ]]
        local opts = {
            configs = { languages = "c++17" },
            links = "systemc",
        }
        assert(package:check_cxxsnippets({test = snippet}, opts),
               "SystemC test program failed to compile/link")
    end)