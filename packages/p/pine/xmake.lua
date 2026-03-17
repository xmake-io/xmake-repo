package("pine")
    set_homepage("https://github.com/canyie/pine")
    set_description("Dynamic java method hook framework on ART. Allowing you to change almost all java methods' behavior dynamically.")

    add_urls("https://github.com/canyie/pine.git", {submodules = false})

    add_versions("2025.11.08", "216d910f18b18430a5d21c510affb221a9833a55")

    add_deps("xz-embedded", "dobby")

    on_install("android", function (package)
        os.cd("core/src/main/cpp")
        io.replace("utils/scoped_local_ref.h", [[#include "macros.h"]], [[#include "macros.h"
#include <cstddef>]], {plain = true})
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c++17")

            add_requires("xz-embedded", "dobby")

            target("pine")
                set_kind("$(kind)")

                add_headerfiles(
                    "(*.h)",
                    "(art/*.h)",
                    "(trampoline/*.h)",
                    "(trampoline/arch/*.h)",
                    "(utils/*.h)",
                    {prefixdir = "pine"})

                add_files(
                    "pine.cpp",
                    "ruler.cpp",
                    "android.cpp",
                    "jni_bridge.cpp",
                    "art/art_method.cpp",
                    "art/thread.cpp",
                    "art/jit.cpp",
                    "trampoline/trampoline_installer.cpp",
                    "utils/memory.cpp",
                    "utils/scoped_memory_access_protection.cpp",
                    "utils/elf_image.cpp",
                    "utils/well_known_classes.cpp")

                if is_arch("armeabi-v7a", "armv7-a") then
                    add_asflags("-arch armv7")
                    add_files(
                        "trampoline/arch/thumb2.cpp",
                        "trampoline/arch/thumb2.S")
                elseif is_arch("arm64-v8a", "arm64") then
                    add_asflags("-arch arm64")
                    add_files(
                        "trampoline/arch/arm64.cpp",
                        "trampoline/arch/arm64.S")
                elseif is_arch("x86", "i386") then
                    add_asflags("-arch x86")
                    add_files("trampoline/arch/x86.cpp")
                end

                add_syslinks("log")
                add_packages("xz-embedded")

            target("pine-enhances")
                set_kind("$(kind)")

                add_files("enhances.cpp")

                add_syslinks("log")
                add_packages("dobby")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pine/art/art_method.h>
            void test() {
                pine::art::ArtMethod* method = pine::art::ArtMethod::New();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
