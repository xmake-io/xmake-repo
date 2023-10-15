-- ref: https://github.com/microsoft/vcpkg/blob/master/ports/breakpad/CMakeLists.txt
add_rules("mode.debug", "mode.release")

set_languages("c++17")

add_requires("libdisasm")

target("breakpad")
    set_kind("$(kind)")

    add_includedirs("src")
    add_headerfiles("src/(google_breakpad/**.h)")
    add_packages("libdisasm")

    if is_plat("android") then
        add_files("android/google_breakpad/Android.mk")
    else
        add_files("src/processor/*.cc")
        remove_files("src/processor/*test*.cc",
                     "src/processor/microdump_stackwalk.cc",
                     "src/processor/synth_minidump.cc",
                     "src/processor/minidump_dump.cc",
                     "src/processor/minidump_stackwalk.cc")
        add_headerfiles("src/(processor/*.h)")
        remove_headerfiles("src/processor/*test*.h", "src/processor/synth_minidump.h")

        add_files("src/common/*.cc", "src/client/*.cc")
        remove_files("src/common/*test*.cc", "src/client/*test*.cc")
        add_headerfiles("src/(common/*.h)", "src/(client/*.h)")
        remove_headerfiles("src/common/*test*.h", "src/client/*test*.h")

        if is_plat("windows") then
            add_defines("UNICODE",
                        "WIN32_LEAN_AND_MEAN",
                        "_CRT_SECURE_NO_WARNINGS",
                        "_CRT_SECURE_NO_DEPRECATE",
                        "_CRT_NONSTDC_NO_DEPRECATE")
            add_files("src/common/windows/*.cc",
                      "src/client/windows/crash_generation/*.cc",
                      "src/client/windows/handler/*.cc")
            remove_files("src/common/windows/*test*.cc",
                         "src/common/language.cc",
                         "src/common/path_helper.cc",
                         "src/common/stabs_to_module.cc",
                         "src/common/stabs_reader.cc",
                         "src/common/dwarf*.cc",
                         "src/client/minidump_file_writer.cc")
            add_headerfiles("src/(common/windows/*.h)",
                            "src/(client/windows/common/*.h)",
                            "src/(client/windows/crash_generation/*.h)",
                            "src/(client/windows/handler/*.h)")
            remove_headerfiles("src/common/windows/*test*.h",
                               "src/common/language.h",
                               "src/common/path_helper.h",
                               "src/common/stabs_to_module.h",
                               "src/common/stabs_reader.h",
                               "src/common/dwarf*.h",
                               "src/client/minidump_file_writer.h")

            add_syslinks("wininet", "dbghelp", "imagehlp")
            if is_kind("shared") then
                add_rules("utils.symbols.export_all", {export_classes = true})
            end
        elseif is_plat("macosx") then
            add_defines("HAVE_MACH_O_NLIST_H")
            add_files("src/common/mac/MachIPC.mm",
                      "src/common/mac/*.cc",
                      "src/client/mac/crash_generation/*.cc",
                      "src/client/mac/handler/*.cc")
            remove_files("src/common/mac/*test*.cc")
            add_headerfiles("src/(common/mac/*.h)",
                            "src/(client/mac/crash_generation/*.h)",
                            "src/(client/mac/handler/*.h)")

            add_frameworks("CoreFoundation")
        else
            add_defines("HAVE_A_OUT_H")
            add_files("src/client/linux/**.cc", "src/common/linux/**.cc")
            remove_files("src/client/linux/sender/*test*.cc",
                         "src/client/linux/handler/*test*.cc",
                         "src/client/linux/microdump_writer/*test*.cc",
                         "src/client/linux/minidump_writer/*test*.cc")
            add_headerfiles("src/(client/linux/**.h)", "src/(common/linux/**.h)")
            add_syslinks("pthread")
        end
    end

    on_config(function (target)
        if target:is_plat("windows") then
            local msvc = target:toolchain("msvc")
            if msvc then
                local envs = msvc:runenvs()
                local VSInstallDir = envs and envs.VSInstallDir
                if VSInstallDir then
                    local dir = path.join(VSInstallDir, "DIA SDK")
                    target:add("includedirs", path.join(dir, "include"))
                    target:add("syslinks", "diaguids")
                    if os.isdir(dir) then
                        if target:is_arch("x86") then
                            target:add("runenvs", path.join(dir, "bin"))
                            target:add("linkdirs", path.join(dir, "lib"))
                        else
                            local arch
                            if target:is_arch("x64") then
                                arch = "amd64"
                            elseif target:is_arch("arm") then
                                arch = "arm"
                            elseif target:is_arch("arm64") then
                                arch = "arm64"
                            else
                                raise("Unsupported arch")
                            end
                            target:add("runenvs", path.join(dir, "bin", arch))
                            target:add("linkdirs", path.join(dir, "lib", arch))
                        end
                    end
                end
            end
        elseif not target:is_plat("macosx") then
            if target:has_cfuncs("getcontext", {includes = "ucontext.h"}) then
                target:add("defines", "HAVE_GETCONTEXT=1")
            else
                target:add("files", path.join(os.projectdir(), "src/common/linux/breakpad_getcontext.S"))
            end
        end
    end)
