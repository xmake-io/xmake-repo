package("qtpromise")
    set_kind("library", {headeronly = true})
    set_homepage("https://qtpromise.netlify.com")
    set_description("Promises/A+ implementation for Qt/C++")
    set_license("MIT")

    add_urls("https://github.com/simonbrunel/qtpromise/archive/refs/tags/$(version).tar.gz",
             "https://github.com/simonbrunel/qtpromise.git")

    add_versions("v0.7.0", "dda94ad274f667c6f78f1aa0fcd4fc76190d290703c6c3183c2a8413177abc3f")

    add_deps("qt6core")

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", "mingw|x86_64", function (package)
        io.replace("include/QtPromise", "../src/", "", {plain = true})
        os.cp("include", package:installdir())
        os.cp("src/qtpromise", package:installdir("include"))
    end)

    on_test(function (package)
        local cxflags
        if package:is_plat("windows") then
            cxflags = {"/Zc:__cplusplus", "/permissive-"}
        else
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <QtPromise>
            QtPromise::QPromise<QByteArray> test() {
                return {[&](
                    const QtPromise::QPromiseResolve<QByteArray>& resolve,
                    const QtPromise::QPromiseReject<QByteArray>& reject){}};
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}}))
    end)

