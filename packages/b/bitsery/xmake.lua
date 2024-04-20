package("bitsery")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fraillt/bitsery")
    set_description("Header only C++ binary serialization library. It is designed around the networking requirements for real-time data delivery, especially for games.")
    set_license("MIT")

    add_urls("https://github.com/fraillt/bitsery/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fraillt/bitsery.git")
    add_versions("v5.2.3", "896d82ab4ccea9899ff2098aa69ad6d25e524ee1d4c747ce3232d0afe3cd05a5")

    add_patches("5.2.3", path.join(os.scriptdir(), "patches", "5.2.3", "cstdint-include.patch"), "e3c8b80948dba824d8ffa0c3294f9b32ca3001c77a80b45f02a46a1e8586a7e1")

    on_install("windows", "linux", "macosx", "mingw", "bsd", function (package)
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
