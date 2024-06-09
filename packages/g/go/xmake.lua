package("go")
    set_kind("binary")
    set_homepage("https://golang.org/")
    set_description("The Go Programming Language")

    if is_host("windows") then
        if os.arch() == "x64" then
            set_urls("https://go.dev/dl/go$(version).windows-amd64.zip")
            add_versions("1.17.6", "5bf8f87aec7edfc08e6bc845f1c30dba6de32b863f89ae46553ff4bbcc1d4954")
            add_versions("1.22.2", "8e581cf330f49d3266e936521a2d8263679ef7e2fc2cbbceb85659122d883596")
            add_versions("1.22.4", "26321c4d945a0035d8a5bc4a1965b0df401ff8ceac66ce2daadabf9030419a98")
        else
            set_urls("https://go.dev/dl/go$(version).windows-386.zip")
            add_versions("1.17.6", "3809c4e40482ff047200c8b1e22a43a2c9c79b53ef540668d2b00f7228f093aa")
            add_versions("1.22.2", "651753c06df037020ef4d162c5b273452e9ba976ed17ae39e66ef7ee89d8147e")
            add_versions("1.22.4", "aca4e2c37278a10f1c70dd0df142f7d66b50334fcee48978d409202d308d6d25")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            set_urls("https://go.dev/dl/go$(version).linux-amd64.tar.gz")
            add_versions("1.17.6", "231654bbf2dab3d86c1619ce799e77b03d96f9b50770297c8f4dff8836fc8ca2")
            add_versions("1.22.2", "5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17")
            add_versions("1.22.4", "ba79d4526102575196273416239cca418a651e049c2b099f3159db85e7bade7d")
        elseif os.arch() == "i386" then
            set_urls("https://go.dev/dl/go$(version).linux-386.tar.gz")
            add_versions("1.17.6", "06c50fb0d44bb03dd4ea8795f9448379c5825d2765307b51f66905084c3ba541")
            add_versions("1.22.2", "586d9eb7fe0489ab297ad80dd06414997df487c5cf536c490ffeaa8d8f1807a7")
            add_versions("1.22.4", "47a2a8d249a91eb8605c33bceec63aedda0441a43eac47b4721e3975ff916cec")
        elseif os.arch() == "arm64" then
            set_urls("https://go.dev/dl/go$(version).linux-arm64.tar.gz")
            add_versions("1.17.6", "82c1a033cce9bc1b47073fd6285233133040f0378439f3c4659fe77cc534622a")
            add_versions("1.22.2", "36e720b2d564980c162a48c7e97da2e407dfcc4239e1e58d98082dfa2486a0c1")
            add_versions("1.22.4", "a8e177c354d2e4a1b61020aca3562e27ea3e8f8247eca3170e3fa1e0c2f9e771")
        end
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            set_urls("https://go.dev/dl/go$(version).darwin-amd64.tar.gz")
            add_versions("1.17.6", "874bc6f95e07697380069a394a21e05576a18d60f4ba178646e1ebed8f8b1f89")
            add_versions("1.22.2", "33e7f63077b1c5bce4f1ecadd4d990cf229667c40bfb00686990c950911b7ab7")
            add_versions("1.22.4", "c95967f50aa4ace34af0c236cbdb49a9a3e80ee2ad09d85775cb4462a5c19ed3")
        elseif os.arch() == "arm64" then
            set_urls("https://go.dev/dl/go$(version).darwin-arm64.tar.gz")
            add_versions("1.22.2", "660298be38648723e783ba0398e90431de1cb288c637880cdb124f39bd977f0d")
            add_versions("1.22.4", "242b78dc4c8f3d5435d28a0d2cec9b4c1aa999b601fb8aa59fb4e5a1364bf827")
        end
    end

    on_install("macosx", "linux", "windows", function (package)
        os.cp("bin", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("pkg", package:installdir())
        os.cp("misc", package:installdir())
        os.cp("src", package:installdir())
    end)

    on_test(function (package)
        os.vrun("go env")
    end)
