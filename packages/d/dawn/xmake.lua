package("dawn")
    set_homepage("https://dawn.googlesource.com/dawn")
    set_description("Dawn, a WebGPU implementation")
    set_license("BSD-3-Clause")

    if is_plat("wasm") then
        -- emdawnwebgpu, Dawn's webgpu.h for Emscripten, is an Emscripten port that emcc builds itself
        set_kind("library", {headeronly = true})
        add_urls("https://github.com/google/dawn/releases/download/v$(version)/emdawnwebgpu_pkg-v$(version).zip")

        add_versions("20261009.190412", "639b1551ffc98ea81f748bfcf311fb3c416464408b4fc1de818c5fae6240786d")
    else
        add_urls("https://github.com/google/dawn/archive/refs/tags/v$(version).tar.gz")

        add_versions("20261009.190412", "cdec5661e0650646051aa62f6aafb4d08122252ed5e5baadc36ece2a48dcc2b2")

        -- sources Dawn needs at the commits pinned in its DEPS file: when adding a version, take the commits of
        -- third_party/spirv-headers/src, spirv-tools/src and webgpu-headers/src from that release's DEPS (the
        -- OpenGL-Registry/src commit for gl.xml); any recent jinja2 and markupsafe release works
        add_resources("20261009.190412", "jinja2", "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz", "0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d")
        add_resources("20261009.190412", "markupsafe", "https://files.pythonhosted.org/packages/38/9b/e422a865e1d5d57d0e509b4e0bf1c1a70a7f6382c29a5aa428df994c8bc8/markupsafe-3.0.4.tar.gz", "2e9ad7dd851bf45fab9f75cbff4cb493fee9979e8d8c7c9c3ee119022518edd6")
        add_resources("20261009.190412", "spirv_headers", "https://github.com/KhronosGroup/SPIRV-Headers/archive/86f980c731e62ae4eaf383d320449d71687936bf.tar.gz", "d11ef011d0788ed002d7cc96224d298f43b126cabe887cd4d46199cb19ecf386")
        add_resources("20261009.190412", "spirv_tools", "https://github.com/KhronosGroup/SPIRV-Tools/archive/e56740d931256cc464d4d1a76149f69469c33f70.tar.gz", "33813160942db93b56232ab93887b39dc0c25b2fa934469fb2428dab5a5626c9")
        add_resources("20261009.190412", "webgpu_headers", "https://github.com/webgpu-native/webgpu-headers/archive/a1dc77409bb2b8bd80540cbf4b8db219e123e909.tar.gz", "57821050e8eb31295a259bd29f5c0b6ff5c228fd2e77f7cf03c32652c29c23ad")
        add_resources("20261009.190412", "gl_xml", "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/6af574a14089ccfee87efe230ebcdd8742859813/xml/gl.xml", "b9ca2cfa5c676e901c20d34af3407f1687cde0f1336a5ff7a8974d04c7494ad3")
    end

    add_configs("d3d11", {description = "Enable the Direct3D 11 backend.", default = is_plat("windows"), type = "boolean"})
    add_configs("d3d12", {description = "Enable the Direct3D 12 backend.", default = is_plat("windows"), type = "boolean"})
    add_configs("metal", {description = "Enable the Metal backend.", default = is_plat("macosx", "iphoneos"), type = "boolean"})
    add_configs("vulkan", {description = "Enable the Vulkan backend.", default = is_plat("windows", "linux", "android"), type = "boolean"})
    add_configs("opengl", {description = "Enable the desktop OpenGL backend.", default = is_plat("linux"), type = "boolean"})
    add_configs("opengles", {description = "Enable the OpenGL ES backend.", default = is_plat("linux", "android"), type = "boolean"})
    add_configs("x11", {description = "Enable X11 surfaces.", default = is_plat("linux"), type = "boolean"})
    add_configs("wayland", {description = "Enable Wayland surfaces.", default = is_plat("linux"), type = "boolean"})

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    if on_check then
        on_check("windows", "linux", "macosx", "android", "iphoneos", function (package)
            -- Tint relies on class template argument deduction for aggregates (clang >= 17, Xcode >= 16)
            assert(package:check_cxxsnippets({test = [[
                template <class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
                void test() {
                    auto f = overloaded{[](int) {}, [](float) {}};
                    f(1);
                }
            ]]}, {configs = {languages = "c++20"}}), "package(dawn): requires a C++20 compiler with aggregate deduction (e.g. clang >= 17, Xcode >= 16)")
        end)
    end

    on_load(function (package)
        if package:is_plat("wasm") then
            local port = "--use-port=" .. path.join(package:installdir(), "emdawnwebgpu.port.py")
            package:add("cxflags", port)
            package:add("ldflags", port)
            return
        end
        package:add("links", "webgpu_dawn")
        package:add("deps", "cmake", "python 3.x", {kind = "binary"})
        package:add("deps", "abseil")
        if package:config("shared") then
            package:add("defines", "WGPU_SHARED_LIBRARY", "DAWN_NATIVE_SHARED_LIBRARY")
        end
        -- only their headers are used: Dawn loads the system libraries at runtime
        if package:config("vulkan") then
            package:add("deps", "vulkan-headers", "vulkan-utility-libraries", {private = true})
        end
        if package:config("opengl") or package:config("opengles") then
            package:add("deps", "egl-headers", {private = true})
        end
        if package:config("x11") then
            package:add("deps", "libx11", "libxcb", {private = true})
        end
        if not package:config("shared") then
            if package:is_plat("windows") then
                package:add("syslinks", "user32", "onecore_apiset")
                if package:config("d3d11") or package:config("d3d12") then
                    package:add("syslinks", "dxguid")
                end
            elseif package:is_plat("linux") then
                package:add("syslinks", "dl", "pthread")
            elseif package:is_plat("android") then
                package:add("syslinks", "log")
            end
            if package:is_plat("macosx", "iphoneos") then
                package:add("frameworks", "Foundation", "IOSurface")
                if package:config("metal") then
                    package:add("frameworks", "Metal", "QuartzCore")
                end
                if package:is_plat("macosx") then
                    package:add("frameworks", "Cocoa", "IOKit")
                end
            end
        end
    end)

    on_install("windows|x64", "windows|arm64", "linux", "macosx", "android", "iphoneos", function (package)
        -- the pinned sources go where Dawn expects its git submodules: their resource paths are too long
        -- for Windows, so they are moved (renaming a folder doesn't touch the long paths inside it)
        local resources = {
            jinja2 = {"src/jinja2", "third_party/jinja2"},
            markupsafe = {"src/markupsafe", "third_party/markupsafe"},
            spirv_headers = {nil, "third_party/spirv-headers/src"},
            spirv_tools = {nil, "third_party/spirv-tools/src"},
            webgpu_headers = {nil, "third_party/webgpu-headers/src"},
        }
        for name, dirs in pairs(resources) do
            local resourcedir = os.dirs(path.join(package:resourcedir(name), "*"))[1]
            os.rm(dirs[2])
            os.mv(dirs[1] and path.join(resourcedir, dirs[1]) or resourcedir, dirs[2])
        end

        -- abseil and the Vulkan headers come from their packages: Dawn only builds its own copies when
        -- these targets don't exist yet
        local deps = {"find_package(absl CONFIG REQUIRED GLOBAL)"}
        if package:config("vulkan") then
            table.insert(deps, "find_package(VulkanHeaders CONFIG REQUIRED GLOBAL)")
            table.insert(deps, "find_package(VulkanUtilityLibraries CONFIG REQUIRED GLOBAL)")
        end
        io.writefile("xmake-deps.cmake", table.concat(deps, "\n") .. "\n")

        -- the libraries bundled into webgpu_dawn are Dawn's own: link imported ones instead
        io.replace("src/cmake/BundleLibraries.cmake", [[
  foreach(dependency IN LISTS all_dependencies)
    get_target_property(type ${dependency} TYPE)]], [[
  set(imported_libraries "")
  foreach(dependency IN LISTS all_dependencies)
    get_target_property(imported ${dependency} IMPORTED)
    if(imported)
      list(APPEND imported_libraries ${dependency})
      continue()
    endif()
    get_target_property(type ${dependency} TYPE)]], {plain = true})
        io.replace("src/cmake/BundleLibraries.cmake", [[
  add_dependencies(${output_target} ${ARGN})]], [[
  add_dependencies(${output_target} ${ARGN})
  target_link_libraries(${output_target} PRIVATE ${imported_libraries})]], {plain = true})

        local configs = {
            "-DCMAKE_PROJECT_Dawn_INCLUDE=" .. path.join(os.curdir(), "xmake-deps.cmake"),
            "-DDAWN_ENABLE_INSTALL=ON",
            "-DDAWN_FETCH_DEPENDENCIES=OFF",
            "-DDAWN_BUILD_SAMPLES=OFF",
            "-DDAWN_BUILD_TESTS=OFF",
            "-DDAWN_BUILD_BENCHMARKS=OFF",
            "-DDAWN_BUILD_PROTOBUF=OFF",
            "-DDAWN_BUILD_NODE_BINDINGS=OFF",
            "-DDAWN_USE_GLFW=OFF",
            "-DDAWN_USE_BUILT_DXC=OFF",
            "-DDAWN_ENABLE_NULL=ON",
            "-DDAWN_SUPPORTS_CXX_MODULES=OFF",
            "-DTINT_BUILD_TESTS=OFF",
            "-DTINT_BUILD_CMD_TOOLS=OFF",
            "-DTINT_ENABLE_INSTALL=OFF",
            "-DBUILD_SHARED_LIBS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DDAWN_BUILD_MONOLITHIC_LIBRARY=" .. (package:config("shared") and "SHARED" or "STATIC"))
        table.insert(configs, "-DDAWN_ENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_ENABLE_D3D11=" .. (package:config("d3d11") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_ENABLE_D3D12=" .. (package:config("d3d12") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_ENABLE_METAL=" .. (package:config("metal") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_ENABLE_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_ENABLE_DESKTOP_GL=" .. (package:config("opengl") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_ENABLE_OPENGLES=" .. (package:config("opengles") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_USE_X11=" .. (package:config("x11") and "ON" or "OFF"))
        table.insert(configs, "-DDAWN_USE_WAYLAND=" .. (package:config("wayland") and "ON" or "OFF"))

        if package:config("opengl") or package:config("opengles") then
            -- Dawn reads the EGL headers from api/ and generates its OpenGL loader from xml/gl.xml
            local khronos = path.absolute("xmake-khronos")
            os.cp(path.join(package:dep("egl-headers"):installdir("include"), "*"), path.join(khronos, "api") .. "/")
            os.cp(package:resourcefile("gl_xml"), path.join(khronos, "xml", "gl.xml"))
            table.insert(configs, "-DDAWN_EGL_REGISTRY_DIR=" .. khronos)
            table.insert(configs, "-DDAWN_OPENGL_REGISTRY_DIR=" .. khronos)
        end

        local packagedeps = {}
        if package:config("x11") then
            -- Dawn includes Xlib-xcb.h, but CMake's FindX11 leaves out the xcb headers
            table.insert(packagedeps, package:dep("libxcb"))
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_install("wasm", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <webgpu/webgpu_cpp.h>
            void test() {
                wgpu::InstanceDescriptor descriptor{};
                wgpu::Instance instance = wgpu::CreateInstance(&descriptor);
            }
        ]]}, {configs = {languages = "c++20"}}))
        if not package:is_plat("wasm") then
            assert(package:check_cxxsnippets({test = [[
                #include <dawn/native/DawnNative.h>
                void test() {
                    const DawnProcTable& procs = dawn::native::GetProcs();
                    (void)procs;
                }
            ]]}, {configs = {languages = "c++20"}}))
        end
    end)
