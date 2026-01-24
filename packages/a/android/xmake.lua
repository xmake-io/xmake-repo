package("android")
    set_homepage("https://android.googlesource.com/platform/frameworks/base")
    set_description("")

    add_urls("https://android.googlesource.com/platform/manifest.git")

    add_versions("2024.10.01", "7f9b5893c3d20455fd57b7b56527cd9a63311cab")

    add_deps("repo")

    includes(path.join(os.scriptdir(), "configs.lua"))
    for _, name in ipairs(get_android_projects()) do
        add_configs(name, {default = false, type = "boolean"})
    end

    on_install(function (package)
        local projects_enabled = {}
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") and enabled then
                table.insert(projects_enabled, name)
            end
        end
        os.vrun("repo init --partial-clone -b main -u https://android.googlesource.com/platform/manifest")
        for _, project_name in ipairs(projects_enabled) do
            os.vrun("repo sync " .. project_name)
        end
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
    end)
