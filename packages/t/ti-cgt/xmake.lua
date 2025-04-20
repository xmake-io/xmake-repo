package("ti-cgt")
    set_kind("toolchain")
    set_homepage("https://www.ti.com")
    set_description("TI CGT (code generate tool) are TI's compilers for TI C2000 DSP, TI C6000 DSP, TI Arm board.")

    if is_host("windows") then
        add_urls("https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-vqU2jj6ibH/$(version)/ti_cgt_c6000_$(version)_windows-x64_installer.exe")

        add_versions("8.3.13", "48d6a56f447e6b44f18bdcb4d1338362ef2eda2e3d329f38b296c63b21964b91")
        add_versions("8.3.12", "7273edf24f82eb5ac8192a2b74b4660c63a5b591e567b46ddce19db015704ab2")
    elseif is_host("linux") then
        add_urls("https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-vqU2jj6ibH/$(version)/ti_cgt_c6000_$(version)_linux-x64_installer.bin")

        add_versions("8.3.13", "436d9cda768e042e61fd6ab1293d008eb23cc167b2a9a7db49766cd94d8f6bcd")
        add_versions("8.3.12", "050518940e4cdbd2068ca1b490426f1d008e80b89d617efbc0c40f432869e09a")
    elseif is_host("macosx") then
        add_urls("https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-vqU2jj6ibH/$(version)/ti_cgt_c6000_$(version)_osx_installer.app.zip")

        add_versions("8.3.13", "fff6e2c55f2535bbf01e991c7de1e75e4d0c6610acef4d5801a6342ae25ae096")
    end

    on_install("windows|x64", "linux|x86_64", function(package)
        local version = package:version()
        local installer = "ti_cgt_c6000_" .. version .. "_"
        if is_host("windows") then
            installer = "../" .. installer .. "windows-x64_installer.exe"
        else
            if is_host("linux") then
                installer = "../" .. installer .. "linux-x64_installer.bin"
            elseif is_host("macosx") then
                os.cd(installer .."osx_installer.app/Contents/MacOS")
                installer = "installbuilder.sh"
                -- TODO
            end
            os.vrunv("chmod", {"+x", installer})
        end

        os.vrunv(installer, {"--mode", "unattended", "--prefix", os.curdir()})
        os.vcp("ti-cgt-c6000_" .. version .."/bin", package:installdir())
        os.vcp("ti-cgt-c6000_" .. version .."/lib", package:installdir())
        os.vcp("ti-cgt-c6000_" .. version .."/include", package:installdir())
    end)

    on_test(function (package)
        os.vrun("cl6x -h Include")
    end)
