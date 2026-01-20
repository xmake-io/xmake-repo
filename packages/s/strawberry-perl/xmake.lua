package("strawberry-perl")

    set_kind("binary")
    set_homepage("http://strawberryperl.com/")
    set_description("Strawberry Perl is a perl environment for MS Windows containing all you need to run and develop perl applications.")

    if os.arch() == "x64" or os.arch() == "x86_64" then
        add_urls("https://github.com/xmake-mirror/strawberry-perl/releases/download/$(version)/strawberry-perl-$(version)-64bit.zip",
            {version = function (version) return version:gsub("%+", ".") end})
        add_urls("http://strawberryperl.com/download/$(version)/strawberry-perl-$(version)-64bit.zip",
            {version = function (version) return version:gsub("%+", ".") end})
        add_versions("5.32.0+1", "24601fdadd25f921501f04505895d2061a8d8ccfbe515241ceddbd2c372fe78e")
    else
        add_urls("https://github.com/xmake-mirror/strawberry-perl/releases/download/$(version)/strawberry-perl-$(version)-32bit.zip",
            {version = function (version) return version:gsub("%+", ".") end})
        add_urls("http://strawberryperl.com/download/$(version)/strawberry-perl-$(version)-32bit.zip",
            {version = function (version) return version:gsub("%+", ".") end})
        add_versions("5.32.0+1", "0888c87cb99e42a209f7d6b03fd3a72eda53c647b1c27060913e224f644ab866")
    end

    add_configs("mingw", {description = "Export built-in MinGW binaries.", default = false, type = "boolean"})

    on_fetch("@windows", function (package, opt)
        if opt.system then
            return package:find_tool("perl", {check = function()
                return os.iorunv("perl", {"-MFile::Spec::Functions=rel2abs", "-e", "print rel2abs('.')"})
            end})
        end
    end)

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.mv("perl", package:installdir())
        os.mv("c", package:installdir())
        os.mv("reloc*", package:installdir())
        os.cd(package:installdir())
        os.vrun("relocation.pl.bat")
        package:addenv("PATH", path.join("perl", "bin"))
        if package:config("mingw") then
            package:addenv("PATH", path.join("c", "bin"))
        end
    end)

    on_test(function (package)
        os.vrun("perl -v")
        if package:config("mingw") then
            os.vrun("gcc -v")
        end
    end)
