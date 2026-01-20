package("rapidcsv")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/d99kris/rapidcsv")
    set_description("C++ header-only library for CSV parsing (by d99kris)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/d99kris/rapidcsv/archive/refs/tags/$(version).zip",
             "https://github.com/d99kris/rapidcsv.git")

    add_versions("v8.90", "8f05816809a303a926e98f798d4ef63083b9c74d411703bc8e8b5a0166d3eb12")
    add_versions("v8.89", "592baaf91a21aa6a343103c36c1236000dd4824229a78530dc39867c70ff1ae8")
    add_versions("v8.88", "14cc4a773c4c045daafac5d21e1f9f83d874be12e9263bb0fde3ee478bb88c5e")
    add_versions("v8.87", "8114915a557cb5c972a27767dc92874ceae7f749def82fb522c118130602ced5")
    add_versions("v8.85", "c53bd40846068ad8843eaa0d089934be92014d77e7fd0a0ae3b0a0893c76e74f")
    add_versions("v8.84", "6226df921e392eb5fa88dd1efaf26a1a7cfdc23bc00c08a7337fc0314bf8b5a8")
    add_versions("v8.83", "ca7e99a7229d50a8d7e59d77f31b53970579429c71bf05bc53729d15135c9b6f")
    add_versions("v8.82", "e07c9355846b62b960ddebf79fef306ac21ee297f19880f237b7da8eb007a056")
    add_versions("v8.80", "5bdbecc3542a881c058624d63c27574fa171fafe32be857e925fccaa1ae75f46")
    add_versions("v8.50", "c7822b590f48f7d8c9b560a6e2d7e29d7ec2f7b3642eb75ddff40a803949b502")

    on_install(function (package)
        os.cp("src/rapidcsv.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                rapidcsv::Document doc("example.csv");
                doc.GetColumn<float>("Example").size();
            }
        ]]}, {includes = "rapidcsv.h", configs = {languages = "c++17"}}))
    end)
