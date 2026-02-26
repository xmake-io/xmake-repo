import("core.base.option")
import("package.tools.make")

function add_urls(package, scheme_name)
    local scheme = package
    if scheme_name then
        scheme = package:scheme(scheme_name)
    end
    scheme:add("urls", "https://github.com/Kitware/CMake/releases/download/v$(version)/cmake-$(version).tar.gz")
    scheme:add("versions", "3.18.4", "597c61358e6a92ecbfad42a9b5321ddd801fc7e7eca08441307c9138382d4f77")
    scheme:add("versions", "3.21.0", "4a42d56449a51f4d3809ab4d3b61fd4a96a469e56266e896ce1009b5768bd2ab")
    scheme:add("versions", "3.22.1", "0e998229549d7b3f368703d20e248e7ee1f853910d42704aa87918c213ea82c0")
    scheme:add("versions", "3.24.1", "4931e277a4db1a805f13baa7013a7757a0cbfe5b7932882925c7061d9d1fa82b")
    scheme:add("versions", "3.24.2", "0d9020f06f3ddf17fb537dc228e1a56c927ee506b486f55fe2dc19f69bf0c8db")
    scheme:add("versions", "3.26.4", "313b6880c291bd4fe31c0aa51d6e62659282a521e695f30d5cc0d25abbd5c208")
    scheme:add("versions", "3.28.1", "15e94f83e647f7d620a140a7a5da76349fc47a1bfed66d0f5cdee8e7344079ad")
    scheme:add("versions", "3.28.3", "72b7570e5c8593de6ac4ab433b73eab18c5fb328880460c86ce32608141ad5c1")
    scheme:add("versions", "3.29.2", "36db4b6926aab741ba6e4b2ea2d99c9193222132308b4dc824d4123cb730352e")
    scheme:add("versions", "3.30.1", "df9b3c53e3ce84c3c1b7c253e5ceff7d8d1f084ff0673d048f260e04ccb346e1")
    scheme:add("versions", "3.30.2", "46074c781eccebc433e98f0bbfa265ca3fd4381f245ca3b140e7711531d60db2")
    scheme:add("versions", "4.0.0",  "ddc54ad63b87e153cf50be450a6580f1b17b4881de8941da963ff56991a4083b")
    scheme:add("versions", "4.0.1",  "d630a7e00e63e520b25259f83d425ef783b4661bdc8f47e21c7f23f3780a21e1")
    scheme:add("versions", "4.0.2",  "1c3a82c8ca7cf12e0b17178f9d0c32f7ac773bd5651a98fcfd80fbf4977f8d48")
    scheme:add("versions", "4.0.3",  "8d3537b7b7732660ea247398f166be892fe6131d63cc291944b45b91279f3ffb")
    scheme:add("versions", "4.1.4",  "a728a8ae5846aecbe3f4fea1405d809a6455ac7d1ed1f80c1fcf82f48d071ee1")
    scheme:add("versions", "4.2.1",  "414aacfac54ba0e78e64a018720b64ed6bfca14b587047b8b3489f407a14a070")
end

function install(package)
    local configs = {"--parallel=" .. (option.get("jobs") or tostring(os.default_njob())),
        "--prefix=" .. package:installdir()}
    if is_host("linux") then
        table.insert(configs, "--")
        table.insert(configs, "-DCMAKE_USE_OPENSSL=OFF")
    end
    os.vrunv("sh", table.join({"./bootstrap"}, configs))
    make.install(package)
end
