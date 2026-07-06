package("brainflow")
    set_homepage("https://github.com/brainflow-dev/brainflow")
    set_description("BrainFlow is a library intended to obtain, parse and analyze EEG, EMG, ECG and other kinds of data from biosensors.")
    set_license("MIT")

    add_urls("https://github.com/brainflow-dev/brainflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brainflow-dev/brainflow.git")
    add_versions("5.22.2", "a7e21b1b9d086370496282a5198c904cb25199cacd9c6a809b9adce544fcbe36")
    add_versions("5.20.1", "0f01f00025c67ce52745be26ebc049d1ba68d398c3fe5a6df6c766c3bf6d40ce")

    add_deps("cmake")

    on_load(function (package)
        package:add("includedirs", "inc")
        package:add("links", "Brainflow", "BoardController", "DataHandler", "MLModule")

        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread", "dl")
        end
    end)

    -- Windows (MSVC) is intentionally omitted: BrainFlow only supports an MSVC
    -- build with the Windows 8.1 SDK (https://github.com/brainflow-dev/brainflow/blob/master/.github/workflows/run_windows.yml)
    -- and does not target Windows on ARM at all, so it does not compile against a recent MSVC/SDK.
    on_install("linux", "macosx", "bsd", function (package)
        local configs = {
            "-DBUILD_TESTS=OFF",
            "-DBUILD_BLUETOOTH=OFF",
            "-DBUILD_BLE=OFF",
            "-DBUILD_ONNX=OFF",
            "-DBUILD_PERIPHERY=OFF",
            "-DBUILD_OYMOTION_SDK=OFF",
            "-DBUILD_SYNCHRONI_SDK=OFF",
            "-DUSE_LIBFTDI=OFF",
            "-DUSE_OPENMP=OFF",
            "-DWARNINGS_AS_ERRORS=OFF",
            "-DBUILD_SHARED_LIBS=OFF"
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        local version = package:version()
        if version then
            table.insert(configs, "-DBRAINFLOW_VERSION=" .. tostring(version))
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "board_shim.h"
            int main() {
                auto version = BoardShim::get_version();
                return version.empty();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
