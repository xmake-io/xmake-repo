package("qengine")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Chemiculs/qengine")
    set_description("C++ 17 or higher control flow obfuscation library for windows binaries")
    set_license("MIT")

    add_urls("https://github.com/Chemiculs/qengine/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Chemiculs/qengine.git", {
        version = function (version)
            return version:gsub("+", ".")
        end
    })

    add_versions("1.1.1+3", "21e5e2a856128fc73648cabffec83d86b365fbd637538570dafff272f7833dfa")

    add_deps("capstone", "asmjit")

    on_install("windows", function (package)
        io.replace("src/qengine/qhook/qhook_dtc.hpp",
            "../extern/capstone/include/capstone/capstone.h",
            "capstone/capstone.h", {plain = true})

        io.replace("src/qengine/qhook/qhook_dtc.hpp", [[#pragma comment(lib, "capstone32.lib")]], "", {plain = true})
        io.replace("src/qengine/qhook/qhook_dtc.hpp", [[#pragma comment(lib, "capstone64.lib")]], "", {plain = true})

        io.replace("src/qengine/qmorph/qdisasm.hpp",
            "../extern/capstone/include/capstone/capstone.h",
            "capstone/capstone.h", {plain = true})

        io.replace("src/qengine/qmorph/qdisasm.hpp", [[#pragma comment(lib, "capstone32.lib")]], "", {plain = true})
        io.replace("src/qengine/qmorph/qdisasm.hpp", [[#pragma comment(lib, "capstone64.lib")]], "", {plain = true})

        io.replace("src/qengine/qmorph/qgen.hpp",
            "../extern/asmjit/asmjit.h",
            "asmjit/asmjit.h", {plain = true})

        io.replace("src/qengine/qmorph/qgen.hpp", "_abi_1_10", "_abi_1_13", {plain = true})
        io.replace("src/qengine/qmorph/qgen.hpp", [[#pragma comment(lib, "asmjit32.lib")]], "", {plain = true})
        io.replace("src/qengine/qmorph/qgen.hpp", [[#pragma comment(lib, "asmjit64.lib")]], "", {plain = true})
        io.replace("src/qengine/qmorph/qgen.hpp", [[#pragma comment(lib, "asmjit_d32.lib")]], "", {plain = true})
        io.replace("src/qengine/qmorph/qgen.hpp", [[#pragma comment(lib, "asmjit_d64.lib")]], "", {plain = true})

        os.vrm("src/qengine/extern")
        os.vcp("src/qengine", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                qengine::qtype_enc::qe_string my_string_e("Hello World!");
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"qengine/engine/qengine.hpp"}}))
    end)
