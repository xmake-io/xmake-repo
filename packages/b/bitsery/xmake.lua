package("bitsery")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fraillt/bitsery")
    set_description("Header only C++ binary serialization library. It is designed around the networking requirements for real-time data delivery, especially for games.")
    set_license("MIT")

    add_urls("https://github.com/fraillt/bitsery/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fraillt/bitsery.git")
    add_versions("v5.2.5", "22a6d92ac030e999b53d57a0c9afe28723766595c6d00c91ab9c5637d4ed0eec")
    add_versions("v5.2.4", "ff741a3fee5420b31af31c7a8cefbcc3aaaf6f7f8c3ac49aa020f99b21d96020")
    add_versions("v5.2.3", "896d82ab4ccea9899ff2098aa69ad6d25e524ee1d4c747ce3232d0afe3cd05a5")

    add_patches("5.2.3", path.join(os.scriptdir(), "patches", "5.2.3", "cstdint-include.patch"), "bb9ea1f68b219249395f3f3f9404d6e5c150144d793b6707f51facd1ff751f2c")

    on_install(function (package)
        os.cp(path.join("include", "*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            enum class MyEnum:uint16_t { V1,V2,V3 };
            struct MyStruct {
                uint32_t i;
                MyEnum e;
                std::vector<float> fs;
            };

            template <typename S>
            void serialize(S& s, MyStruct& o) {
                s.value4b(o.i);
                s.value2b(o.e);
                s.container4b(o.fs, 10);
            }

            using Buffer = std::vector<uint8_t>;
            using OutputAdapter = bitsery::OutputBufferAdapter<Buffer>;
            using InputAdapter = bitsery::InputBufferAdapter<Buffer>;

            void test() {
                MyStruct data{8941, MyEnum::V2, {15.0f, -8.5f, 0.045f}};
                MyStruct res{};

                Buffer buffer;

                auto writtenSize = bitsery::quickSerialization<OutputAdapter>(buffer, data);
                auto state = bitsery::quickDeserialization<InputAdapter>({buffer.begin(), writtenSize}, res);

                assert(state.first == bitsery::ReaderError::NoError && state.second);
                assert(data.fs == res.fs && data.i == res.i && data.e == res.e);
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"bitsery/bitsery.h", "bitsery/adapter/buffer.h", "bitsery/traits/vector.h"}}))
    end)
