package("esp32-arduino-libs")
    set_kind("library")
    set_homepage("https://github.com/espressif/arduino-esp32")
    set_description("Prebuilt ESP-IDF libraries, headers, linker scripts and flag sets for the Arduino ESP32 core")
    set_license("LGPL-2.1-or-later")

    -- one archive per chip, the release version is the arduino-esp32 core version
    add_configs("chip", {description = "Set the target ESP chip.", default = "esp32", type = "string",
        values = {"esp32", "esp32s2", "esp32s3", "esp32c3", "esp32c5", "esp32c6", "esp32h2", "esp32p4"}})

    local checksums = {
        ["3.3.11"] = {
            esp32   = "f7d70b98d83482ef9065f13e9dbe21f8c1292f0dc6e6ee9f1970b3b2e5ea894f",
            esp32s2 = "584a2fa2d6e8d9de35233b506bdb60d1492b0fb6de8fa4e7560eb2a3b04aa74a",
            esp32s3 = "fec76794708694120c6ec803cdbfc7dcd36286ea22b7d38097b7909bbd19f7b5",
            esp32c3 = "887067748467a002d9354dc2a14cfd233528e6d89a0b5178db90ba4224e17e5d",
            esp32c5 = "9760dcb7a92306ce169025c74afae104a65c4221f6b1d92c69369748b9cb91f6",
            esp32c6 = "dd7374dabadeced8259ea67c331faa7588afbbed92c2727e7b8c5201f6762ee0",
            esp32h2 = "8a73008ee70bc5a9255798e7732208a533f7d931fa54a2289e5f2c7eed822126",
            esp32p4 = "315868de4dc8cd78fb1b77e07355c605a296abd40ac9d51e78d2b8bd1c61f737"
        },
        ["3.3.10"] = {
            esp32   = "2fbdcf06cef1bff7fb24ca368886ec1678ef67f4a9615f3967d5ce1287557212",
            esp32s2 = "7b6077df9f242b765c8f298270b02f463b17129fdde0700a29338988cf4a921e",
            esp32s3 = "edee967acfbdba03e8baef75d28564e0b74ee10daa640639174b1ae935763302",
            esp32c3 = "a08e1fd34c4be94bf4cfb5589b5a0a5f2908d0392153a0686fd193647bc022f8",
            esp32c5 = "d5981ad02d9358ab7ceb47ae261521c009b46ab2f6ad5ba7d697346e0f3d66b0",
            esp32c6 = "4b9fc7a3ac55af5ac8461302c7129ebcc7a6a4598dbacfb75989fff04d04be7b",
            esp32h2 = "a9706f9c0c66b96864488d48d9377bcb2a46889352df464175ad4b1c17a83e68",
            esp32p4 = "27df1e01518a030b53f7855ee7993cb6ea1d02e4c4848632645ffa2a24ef0155"
        }
    }

    on_source(function (package)
        local chip = package:config("chip")
        package:set("urls", "https://github.com/espressif/arduino-esp32/releases/download/$(version)/" .. chip .. "-libs-$(version).zip")
        for version, chips in pairs(checksums) do
            package:add("versions", version, chips[chip])
        end
    end)

    on_install(function (package)
        os.vcp("*", package:installdir())
    end)

    on_test(function (package)
        local installdir = package:installdir()
        assert(os.isfile(path.join(installdir, "sdkconfig")))
        assert(os.isdir(path.join(installdir, "flags")))
        assert(os.isdir(path.join(installdir, "ld")))
        assert(os.isdir(path.join(installdir, "lib")))
    end)
