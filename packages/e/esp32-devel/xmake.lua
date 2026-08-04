package("esp32-devel")
    set_kind("toolchain")
    set_homepage("https://www.espressif.com/en/products/socs")
    set_description("ESP32 development kit, binds the cross toolchain, prebuilt sdk and flash tool of the selected board")

    -- the xtensa cores and the risc-v cores need different gcc cross toolchains
    local toolchains = {
        esp32   = "xtensa-esp-elf",
        esp32s2 = "xtensa-esp-elf",
        esp32s3 = "xtensa-esp-elf",
        esp32c3 = "riscv32-esp-elf",
        esp32c5 = "riscv32-esp-elf",
        esp32c6 = "riscv32-esp-elf",
        esp32h2 = "riscv32-esp-elf",
        esp32p4 = "riscv32-esp-elf"
    }

    add_configs("board", {description = "Set the target ESP32 board.", default = "esp32", type = "string",
        values = {"esp32", "esp32s2", "esp32s3", "esp32c3", "esp32c5", "esp32c6", "esp32h2", "esp32p4"}})
    add_configs("sdk",   {description = "Bind the prebuilt esp-idf sdk libraries.", default = true, type = "boolean"})
    add_configs("flash", {description = "Bind the flash tool.", default = true, type = "boolean"})

    on_load(function (package)
        local board = package:config("board")
        local toolchain = toolchains[board]
        assert(toolchain, "package(esp32-devel): unsupported board(%s)!", board)
        package:add("deps", toolchain)
        if package:config("flash") then
            package:add("deps", "esptool")
        end
        if package:config("sdk") then
            package:add("deps", "esp32-arduino-libs", {configs = {chip = board}})
        end
    end)

    on_install("windows|x64", "@linux", "@macosx", function (package)
        local board = package:config("board")
        package:addenv("ESP32_BOARD", board)
        package:addenv("ESP32_GCC_PREFIX", toolchains[board] .. "-")
        local sdk = package:dep("esp32-arduino-libs")
        if sdk then
            package:addenv("ESP32_SDK_DIR", sdk:installdir())
        end
    end)

    on_test(function (package)
        local board = package:config("board")
        local gcc = toolchains[board] .. "-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
        if package:config("flash") then
            os.vrunv("esptool", {"version"})
        end
    end)
