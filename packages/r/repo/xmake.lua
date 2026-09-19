package("repo")
    set_kind("binary")
    set_description("Repo is a tool built on top of Git. Repo helps manage many Git repositories, does the uploads to revision control systems, and automates parts of the development workflow.")
    set_homepage("https://gerrit.googlesource.com/git-repo")
    set_license("Apache-2.0")

    add_urls("https://gerrit.googlesource.com/git-repo.git")

    add_versions("v2.48", "69467be0cfc80734b821c54ada263c8f1439f964314063f76b7cf256c3dc7ee8")

    if is_host("linux") then
        add_extsources("apt::repo")
    end

    on_install("linux", function(package)
        os.rm(".git")
        os.cp("*", package:installdir("bin"))
        package:addenv("PATH", package:installdir("bin"))
    end)

    on_test(function(package)
        os.vrun("repo --version")
    end)

