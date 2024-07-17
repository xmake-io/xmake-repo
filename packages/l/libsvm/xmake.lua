package("libsvm")

    set_homepage("https://github.com/cjlin1/libsvm")
    set_description("A simple, easy-to-use, and efficient software for SVM classification and regression")

    add_urls("https://github.com/cjlin1/libsvm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cjlin1/libsvm.git")
    add_versions("v333", "ee898ca11cef85b09e059b278b3ab4ff58cd38f70169829e75b4a3cb9ddc5013")
    add_versions("v332", "e1d7d316112d199ebd69c9695f79226d236b86e2c8d88e70cfe35fd383954ed8")
    add_versions("v325", "1f587ec0df6fd422dfe50f942f8836ac179b0723b768fe9d2fabdfd1601a0963")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("svm")
                set_kind("$(kind)")
                add_files("svm.cpp")
                add_headerfiles("svm.h")
                if is_kind("shared") then
                    add_shflags("/DEF:svm.def")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("svm_train", {includes = "svm.h"}))
    end)
