package("eabase")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/electronicarts/EABase")
    set_description("EABase is a small set of header files that define platform-independent data types and platform feature macros.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/electronicarts/EABase/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/electronicarts/EABase.git", {alias = "git", submodules = false})

    add_versions("2.09.06", "981f922441617152b841585c0fc0bd205bd898c758016fa4985599a63c5a6e16")
    add_versions("2.09.05", "f85b98c96f1976aa013c8d6016c5e37a409633ac3fce843cd4ec0b89c67e6b7a")
    add_patches("2.09.05", "patches/2.09.05/add-arm64-windows.patch", "c140e4587fdb1fc93b16df639da93aac5d331420b86f68363482be31f4bd2bfd")
    add_versions("git:2.09.12", "0699a15efdfd20b6cecf02153bfa5663decb653c")

    on_install("!wasm", function (package)
        os.cp("include/Common/EABase", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("EA_LIMITS_DIGITS_U(int)", {configs = {languages = "c++17"}, includes = "EABase/eabase.h"}))
    end)
