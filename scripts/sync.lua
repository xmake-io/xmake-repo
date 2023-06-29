import("core.base.option")

function main()
    print("update xmake-repo ..")
    os.exec("git clone git@github.com:xmake-io/xmake-repo.git -b dev --recurse-submodules")
    os.cd("xmake-repo")
    os.exec("git push git@gitlab.com:tboox/xmake-repo.git dev")
    os.exec("git push git@gitee.com:tboox/xmake-repo.git dev")
    os.exec("git checkout master")
    os.exec("git merge dev")
    os.exec("git push git@github.com:xmake-io/xmake-repo.git master")
    os.exec("git push git@gitlab.com:tboox/xmake-repo.git master")
    os.exec("git push git@gitee.com:tboox/xmake-repo.git master")
end
