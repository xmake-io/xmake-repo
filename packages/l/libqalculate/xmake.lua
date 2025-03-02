package("libqalculate")
    set_homepage("https://qalculate.github.io/")
    set_description("Qalculate! is a multi-purpose cross-platform desktop calculator.")
    set_license("GPL-2.0")

    add_urls("https://github.com/Qalculate/libqalculate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Qalculate/libqalculate.git")

    add_versions("v5.5.1", "8850a71ceb7a16e8b161edc2f11e2d76bd7c298abe9ddd68f43edf1bdc34aaee")

    if is_plat("linux") then
        add_extsources("apt::libqalculate-dev")
    end

    add_deps("libcurl", "gmp", "icu4c", "mpfr", "readline", "libxml2")

    on_install("linux", "macosx", function (package)
        io.replace("libqalculate/util.cc", "PACKAGE_DATA_DIR", '"' .. package:installdir("share") .. '"', {plain = true})
        io.replace("libqalculate/util.cc", "PACKAGE_LOCALE_DIR", '"' .. package:installdir("share", "locale") .. '"', {plain = true})
        local version = try { function() return io.readfile("configure.ac"):match("AC_INIT%(([%d%.]+)") end }
        version = version or (package:version() and package:version_str():gsub("^v", ""))
        local configs = {version = version}
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Calculator calc;
                calc.calculate("1+1");
            }
        ]]}, {includes = "libqalculate/Calculator.h"}))
        if not package:is_cross() then
            os.vrunv("qalc", {"1+1"})
        end
    end)
