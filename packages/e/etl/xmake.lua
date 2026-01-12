package("etl")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.etlcpp.com")
    set_description("Embedded Template Library")
    set_license("MIT")

    add_urls("https://github.com/ETLCPP/etl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ETLCPP/etl.git")

    add_versions("20.45.0", "97d639b012653af69e2e69b24a816622b7de616fbc9daf3caa12c5cddb5172ba")
    add_versions("20.44.2", "b616558ed10fe4552876bbaa0bf5e98fe5aa32095362ef1843115909159fa2dd")
    add_versions("20.44.1", "e1de3221d16c719470d57437adcde1070eb87ba07b89c9178e680f5e3666beca")
    add_versions("20.44.0", "212d4fc24660ddd22ebba46d36a1f5fcf2438472d64d8417f8713c1c9c3d0a3a")
    add_versions("20.43.4", "0827bc8d27c3765d46a8ee208b05c09e4285e5c3492b530cefc7c3c45fb9fddc")
    add_versions("20.43.3", "44dac7303957b9b86f0970c7b6842e66f0f7546064ae48a9d6f016a0ab8a5c72")
    add_versions("20.43.2", "92eef0153c794c2e49df534123e95447f51cda432051012e452c08205273c012")
    add_versions("20.43.1", "d95821298a41e803134a9753716e55034711f7f4b91d0993c15325be18c6eaef")
    add_versions("20.43.0", "98106a7bc3a858035251868fa8ed036b1a9e3095714bf0b4cbf8c8e51c4d4234")
    add_versions("20.42.2", "32d16f5daae57b97a4c523aed98975c2760b3e9de4dae770b5b199f4602c050a")
    add_versions("20.42.1", "25b7ae3eba614b497ecf17e2f2d749f69ef7e7cd4215347e6cefa8f542712668")
    add_versions("20.42.0", "041321b0ff84baf816ce3572152f3203ba13a534ecbcdd8f14f63e35c5dae7f0")
    add_versions("20.41.7", "10a26f084fcd603bc2b2b8df98221c8896036a558f069acaa1fbaecce7974a39")
    add_versions("20.41.6", "c68a869a26397fe86bba8749132962c2e53104186eb3fc8a26a1713de8a70d1c")
    add_versions("20.41.5", "2f771d36701ed4d219d51fc1ab5c84e6e7e15ba3ee332cd7de11949b1ac33b89")
    add_versions("20.41.4", "7e04d8f6527ba26bfddd55def9ad5911ca0259047b1537aa4c2bb2c80bca8a25")
    add_versions("20.41.3", "f4f620210c4441bc3b7640cad2821fa4c58ade829b7674d62f9f2b1c9718ad11")
    add_versions("20.41.2", "e977b0d6ea3a31f55de4067a47ca1d60e5c8ddaf841b9b1fca5caf1f4071b206")
    add_versions("20.41.1", "d5069a3d2c2da76c60556a5db745db526ec0e3cd400c8cfcbf79813aabfa9650")
    add_versions("20.41.0", "96f0a7992461d6c7060dbaf76aeab85cb7a1ca6f5efc80526bfe61b24819f000")
    add_versions("20.40.1", "9458a1c26f59883f635610521d7ba95da5d1aecb1ff8804a76f5dd2c52e237aa")
    add_versions("20.40.0", "b47ca70e7394f50dd2d65dddfd088757525488ac2fd934f435705fbf3ffe6d3d")
    add_versions("20.39.4", "ce1222ed12fb39ae7a6160f8c33da61534d6b4c4d0d36be622910bbd545f5ee7")
    add_versions("20.39.3", "1d596bc47d17959ced8b4586e0ae22348c903df6ab00f47ef900d854ef5e30c8")
    add_versions("20.39.2", "b1faad1b83382bc7e06df0892b0efe1bd62e8dafe490878b601188f144bef063")
    add_versions("20.39.1", "3fb193011450d5d25b9b221d68f74b9baa970c7fb03ff03426cad56fdead93d6")
    add_versions("20.38.17", "5b490aca3faad3796a48bf0980e74f2a67953967fad3c051a6d4981051cb0b9a")
    add_versions("20.38.16", "6d05e33d6e7eb2c8d4654c77dcd083adc70da29aba808f471ba7c6e2b8fcbf03")
    add_versions("20.38.13", "e606083e189a8fe6211c30c8c579b60c29658a531b5cafbb511daab1a2861a69")
    add_versions("20.38.11", "c73b6b076ab59e02398a9f90a66198a9f8bf0cfa91af7be2eebefb3bb264ba83")
    add_versions("20.38.10", "562f9b5d9e6786350b09d87be9c5f030073e34d7bf0a975de3e91476ddd471a3")
    add_versions("20.38.0", "7e29ce81a2a2d5826286502a2ad5bde1f4b591d2c9e0ef7ccc335e75445223cd")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <etl/array.h>
            void test() {
                etl::array<int, 10> data = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
            }
        ]]}, {configs = {languages = "c++11", defines = "ETL_USE_TYPE_TRAITS_BUILTINS=1"}}))
    end)
