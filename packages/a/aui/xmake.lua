package("aui")
    set_homepage("https://github.com/aui-framework/aui")
    set_description("Declarative UI toolkit for modern C++20")
    set_license("MPL-2.0")

    add_urls("https://github.com/aui-framework/aui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aui-framework/aui.git")

    add_versions("v7.1.2", "a4cf965c50d75e20a319c9c8b231ad9c13c25a06ad303e1eb65d1ff141b1f85c")

    add_patches("v7.1.2", "patches/v7.1.2/debundle-audio.diff", "199f93a75085f9b60c7e735e91cfa47d4316183740c97de9c59988aaf28a0279")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-build.diff", "136de2ca2729b02f729c3bbdb31589436801c27c93622b654e55bc1a72ce3d83")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-core.diff", "708081ddce4be722d81c3cc42c5a11c1b7b2b1aa31a2748c9f94117c48540e58")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-crypt.diff", "92e4ab69e13e0f8743cd581f7c940b10a6ee4830df5c7ea19f721d8986f4a639")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-curl.diff", "322bed6bb924faa82995a4cd5f7cf1cdf3b1e5c09f1ac6b0c7a0cbb55f3f242c")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-image.diff", "4f8f0fb64de19d3fae8aabc08398073963cb956edb1967a6877c958d3d5f8e49")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-json-network.diff", "d71f6bb1cc39ec14e4718c8d401a858a0e514cf0687537c451ded350a3ac2fc5")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-main.diff", "22f975c944d6c59b4fca2ece11176476e6e9423b10b91cc5ddfc5c820ec9821d")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-sqlite.diff", "f27b236e4f9beebcb090d288523f4c64d37700c7e56b6a6ed1776bfaa84c8309")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-toolbox.diff", "10cad07fafef39eba0776cf8a8195040d02532b70e7bbc9599fe29a14f4e23d3")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-views.diff", "6301f160aad25f35af358cc043b417636b8896b6e4231be472a692e789f2535e")
    add_patches("v7.1.2", "patches/v7.1.2/fix-backport-lunasvg.diff", "4a30826ddba1ba708d781593b93cae8c9521be7a157fff514c8f7b805477e6d4")
    add_patches("v7.1.2", "patches/v7.1.2/fix-msvc-pretty-function.diff", "501353756941a706c795b61b25a788bc754f2556fe37bfb4bdd9341d48947c46")
    add_patches("v7.1.2", "patches/v7.1.2/fix-osx-enforce-cpp-template.diff", "e8b11cb86dcf4b6d7ceddb2c70e926385c476515ece94e2149fb9a365475b7f5")
    add_patches("v7.1.2", "patches/v7.1.2/fixup-network.diff", "5a385f757f76d6653e51c4582747a30837f0a852aff8a7210bcc1007edbd188d")
    add_patches("v7.1.2", "patches/v7.1.2/fix-glm.diff", "7bbd5ae3db67b7b372b745b9e7d104292a98dc789457c7e7213d0d7f4ab395f3")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("zlib")

    add_links(
        "aui.audio",
        "aui.json",
        "aui.views",
        "aui.xml",
        "aui.image",
        "aui.curl",
        "aui.crypt",
        "aui.network",
        "aui.core"
    )

    on_check(function (package)
        if package:is_cross() then
            raise("package(aui): does not support cross-compilation now.")
        end
    end)

    -- aui.audio
    on_component("audio", function (package, component)
        package:add("includedirs", "aui.audio/include")
        component:add("links", "aui.audio")
        package:add("deps", "libopus", "soxr")
        if package:is_plat("linux") then
            package:add("deps", "pulseaudio")
        elseif package:is_plat("android") then
            package:add("deps", "oboe")
        elseif package:is_plat("windows", "mingw") then
            component:add("syslinks", "winmm", "dsound", "dxguid")
        elseif package:is_plat("macosx", "iphoneos") then
            component:add("frameworks", "CoreAudio", "AVFoundation", "AudioToolbox")
            if package:is_plat("macosx") then
                component:add("frameworks", "AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore")
            end
        end
    end)

    -- aui.core
    on_component("core", function (package, component)
        package:add("includedirs", "aui.core/include")
        component:add("links", "aui.core")
        package:add("deps", "fmt 9.1.0", "range-v3")
        package:add("deps", "glm", {configs = {header_only = false}})
        if package:is_plat("linux") then
            package:add("deps", "libbacktrace")
            component:add("syslinks", "pthread", "dl")
        elseif package:is_plat("windows", "mingw") then
            component:add("syslinks", "dbghelp", "shell32", "shlwapi", "kernel32", "psapi")
        elseif package:is_plat("android") then
            component:add("syslinks", "log")
        end
    end)

    -- aui.crypt
    on_component("crypt", function (package, component)
        package:add("includedirs", "aui.crypt/include")
        component:add("links", "aui.crypt")
        package:add("deps", "openssl3")
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "wsock32", "ws2_32", "crypt32")
        end
    end)

    -- aui.curl
    on_component("curl", function (package, component)
        package:add("includedirs", "aui.curl/include")
        component:add("links", "aui.curl")
        package:add("deps", "libcurl")
    end)

    -- aui.image
    on_component("image", function (package, component)
        package:add("includedirs", "aui.image/include")
        component:add("links", "aui.image")
        package:add("deps", "lunasvg", "libwebp")
    end)

    -- aui.json
    on_component("json", function (package, component)
        package:add("includedirs", "aui.json/include")
        component:add("links", "aui.json")
    end)

    -- aui.network
    on_component("network", function (package, component)
        package:add("includedirs", "aui.network/include")
        component:add("links", "aui.network")
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "wsock32", "ws2_32", "iphlpapi")
        end
    end)

    -- aui.toolbox
    on_component("toolbox", function (package, component)
        package:add("includedirs", "aui.toolbox/include")
    end)

    -- aui.views
    on_component("views", function (package, component)
        package:add("includedirs", "aui.views/include")
        component:add("links", "aui.views")
        package:add("deps", "freetype")
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            package:add("deps", "glew")
        end
        if package:is_plat("linux") then
            package:add("deps", "libx11", "dbus", "gtk3", "fontconfig")
        end
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "dwmapi", "winmm", "shlwapi", "gdi32", "ole32", "opengl32")
            if package:is_plat("mingw") then
                component:add("syslinks", "uuid")
            end
        elseif package:is_plat("android") then
            component:add("syslinks", "EGL", "GLESv2", "GLESv3")
        elseif package:is_plat("iphoneos") then
            component:add("frameworks", "OpenGLES")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore", "UniformTypeIdentifiers", "OpenGL")
        end
    end)

    -- aui.xml
    on_component("xml", function (package, component)
        package:add("includedirs", "aui.xml/include")
        component:add("links", "aui.xml")
    end)

    on_load(function (package)
        package:add("components", "audio", "core", "crypt", "curl", "image", "json", "network", "toolbox", "views", "xml")
        if not package:config("shared") then
            package:add("defines", "AUI_STATIC")
        end
        package:add("defines", "AUI_DEBUG=" .. (package:is_debug() and "1" or "0"))
        package:add("defines",
            "API_AUI_AUDIO=AUI_IMPORT",
            "API_AUI_CORE=AUI_IMPORT",
            "API_AUI_CRYPT=AUI_IMPORT",
            "API_AUI_CURL=AUI_IMPORT",
            "API_AUI_DATA=AUI_IMPORT",
            "API_AUI_IMAGE=AUI_IMPORT",
            "API_AUI_JSON=AUI_IMPORT",
            "API_AUI_NETWORK=AUI_IMPORT",
            "API_AUI_UITESTS=AUI_IMPORT",
            "API_AUI_UPDATER=AUI_IMPORT",
            "API_AUI_VIEWS=AUI_IMPORT",
            "API_AUI_XML=AUI_IMPORT"
        )
        ----------------------------------------------------------------
        -- helper
        ----------------------------------------------------------------
        function add_flags(pkg, flags, names)
            local defs = {}
            for _, name in ipairs(names) do
                local val = flags[name] or 0
                defs[#defs+1] = string.format("%s=%d", name, val)
            end
            pkg:add("defines", table.unpack(defs))
        end
        ----------------------------------------------------------------
        -- platform
        ----------------------------------------------------------------
        local platform_names = {
            "AUI_PLATFORM_WIN",
            "AUI_PLATFORM_LINUX",
            "AUI_PLATFORM_APPLE",
            "AUI_PLATFORM_MACOS",
            "AUI_PLATFORM_IOS",
            "AUI_PLATFORM_ANDROID",
            "AUI_PLATFORM_UNIX",
            "AUI_PLATFORM_EMSCRIPTEN"
        }

        local platform_map = {
            windows  = { AUI_PLATFORM_WIN = 1 },
            linux    = { AUI_PLATFORM_LINUX = 1,    AUI_PLATFORM_UNIX = 1 },
            macosx   = { AUI_PLATFORM_APPLE = 1,    AUI_PLATFORM_MACOS = 1, AUI_PLATFORM_UNIX = 1 },
            android  = { AUI_PLATFORM_ANDROID = 1,  AUI_PLATFORM_UNIX = 1 },
            iphoneos = { AUI_PLATFORM_APPLE = 1,    AUI_PLATFORM_IOS = 1,   AUI_PLATFORM_UNIX = 1 },
            wasm     = { AUI_PLATFORM_EMSCRIPTEN = 1 },
        }

        for key, flags in pairs(platform_map) do
            local plats = (key == "windows") and {"windows", "mingw"} or {key}
            if package:is_plat(table.unpack(plats)) then
                add_flags(package, flags, platform_names)
                break
            end
        end
        ----------------------------------------------------------------
        -- compiler
        ----------------------------------------------------------------
        local compiler_names = {
            "AUI_COMPILER_CLANG",
            "AUI_COMPILER_GCC",
            "AUI_COMPILER_MSVC",
        }

        local compiler_map = {
            clang = { tools = {"clang", "clangxx", "clang++"}, flags = { AUI_COMPILER_CLANG = 1 } },
            gcc   = { tools = {"gcc",   "gxx",      "g++"   }, flags = { AUI_COMPILER_GCC   = 1 } },
            msvc  = { tools = {"cl",    "clang-cl"          }, flags = { AUI_COMPILER_MSVC  = 1 } },
        }

        for _, info in pairs(compiler_map) do
            if package:has_tool("cxx", table.unpack(info.tools)) then
                add_flags(package, info.flags, compiler_names)
                break
            end
        end
        ----------------------------------------------------------------
        -- architecture
        ----------------------------------------------------------------
        local arch_names = {
            "AUI_ARCH_X86",
            "AUI_ARCH_X86_64",
            "AUI_ARCH_ARM_64",
            "AUI_ARCH_ARM_V7"
        }

        local ptrsize = package:check_sizeof("void*")
        local arch_flags

        if package:is_arch("arm.*") then
            arch_flags = (ptrsize == "4")
                and {AUI_ARCH_ARM_V7 = 1}
                or  {AUI_ARCH_ARM_64 = 1}
        else
            arch_flags = (ptrsize == "4")
                and {AUI_ARCH_X86   = 1}
                or  {AUI_ARCH_X86_64 = 1}
        end

        add_flags(package, arch_flags, arch_names)

        package:add("defines", "GLM_ENABLE_EXPERIMENTAL=1")
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {
            "-DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF",
            "-DAUIB_NO_PRECOMPILED=TRUE",
            "-DAUIB_DISABLE=ON",
        }
        local opt = {}
        if package:is_plat("windows", "mingw") then
            if package:has_tool("cxx", "cl", "clang_cl") then
                opt.cxflags = {"/EHsc"}
            end
            if package:targetarch():startswith("arm") then
                io.replace("cmake/aui.build.cmake", [[if (CMAKE_GENERATOR_PLATFORM MATCHES "(arm64)|(ARM64)" OR CMAKE_SYSTEM_PROCESSOR MATCHES "(aarch64|arm64)")]], [[if (1)]], {plain = true})
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local cmake = import("package.tools.cmake")
        -- gdk-pixbuf-2.0.pc has Requires.private: shared-mime-info when gio_sniffing=true.
        -- shared-mime-info is a binary package so it's not in PKG_CONFIG_PATH, causing
        -- pkg_check_modules(GTK3) to fail. Add it manually.
        if package:is_plat("linux") then
            local smi = package:dep("shared-mime-info")
            if smi then
                local envs = cmake.buildenvs(package, opt)
                local pc_path = path.splitenv(envs.PKG_CONFIG_PATH or "")
                local smi_pc = path.join(smi:installdir(), "share", "pkgconfig")
                if os.isdir(smi_pc) then
                    table.insert(pc_path, smi_pc)
                end
                envs.PKG_CONFIG_PATH = path.joinenv(pc_path)
                opt.envs = envs
            end
        end
        cmake.install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <AUI/Platform/AWindow.h>
            #include <AUI/Util/UIBuildingHelpers.h>
            #include <AUI/View/ALabel.h>
            #include <AUI/View/AButton.h>
            #include <AUI/Platform/APlatform.h>
            #include <AUI/Platform/Entry.h>
            using namespace declarative;
            class MainWindow: public AWindow {
            public:
                MainWindow();
            };
            MainWindow::MainWindow(): AWindow("Project template app", 300_dp, 200_dp) {
                setContents(
                    Centered{
                        Vertical{
                            Centered { Label { "Hello world from AUI!" } },
                            _new<AButton>("Visit GitHub repo").connect(&AView::clicked, this, [] {
                                APlatform::openUrl("https://github.com/aui-framework/aui");
                            }),
                            _new<AButton>("Visit docs").connect(&AView::clicked, this, [] {
                                APlatform::openUrl("https://aui-framework.github.io/");
                            }),
                            _new<AButton>("Submit an issue").connect(&AView::clicked, this, [] {
                                APlatform::openUrl("https://github.com/aui-framework/aui/issues/new");
                            }),
                        }
                    }
                );
            }
            void test() {
                _new<MainWindow>()->show();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
