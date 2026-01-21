package("nodejs")

    set_homepage("https://nodejs.org/")
    set_description("Node.js JavaScript runtime, pre-built from official releases.")
    set_license("MIT")

    includes(path.join(os.scriptdir(), "nodejs-versions.lua"))
    add_nodejs_versions()

    on_install("windows", "linux", "macosx", function(package)
        local extracted_files = os.files("*")
        if #extracted_files == 1 and os.isdir(extracted_files[1]) then
            os.cp(path.join(extracted_files[1], "*"), package:installdir())
        else
            os.cp("*", package:installdir())
        end

        package:addenv("PATH", ".")
    end)

    on_test(function(package)
        os.vrun("node --version")
        if is_plat("windows") then
            os.vrun("npm.cmd --version")
            os.vrun("npx.cmd --version")
        else
            os.vrun("npm --version")
            os.vrun("npx --version")
        end
    end)
