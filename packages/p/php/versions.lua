-- ============================================================
-- 数据表：版本、源码 hash、Windows 各变体 hash
-- devpack hash 需从 https://windows.php.net/download/ 补充
-- ============================================================
php_versions = {
    ["8.5.6"] = {
        source = "4e7baaf0a690e954a20e7ced3dd633ce8cb8094e2b6b612a55e703ecbbdcbf4f",
        win = {
            x64_nts = "e25cc9400a7d176f18074f677ef0159d6b04aecfb255c924d808b7144075092f",
            x64_ts = "38c20264dcfb098cbec3b2b25bc21312e436b87dceadc76725aa1d7cf80be1fc",
            debug_x64_nts = "5cd6ceeed761fa8777bdf388495d825f0ed4730413b76f399ab767560766bbc9",
            debug_x64_ts = "1c51f55ee1a8c4027b95081ec25225e4dca0a3b9af52538c128c5ec3211d19c5",
            x86_nts = "8f56f338afc366164bb675b0f6206db5dabcdd608c5fd176ff874aca78e9a056",
            x86_ts = "eac6c970e692cd6019d66d56ccff67cd845130a8fc831daeedb2b25c1cb1f71d",
            debug_x86_nts = "61bcbf5564b9bc1a415a7c91b7d8008ec4a433ae7e09fc0bc13b756f22b0ddfe",
            debug_x86_ts = "35341def1297a2370e3703e20b883f49d99c3e18ccc6957f7815ee908a9ab90d",
            dev_x64_nts = "76a0b377bfe0ed3e2518c406e5b1038d346e323da3eaf337615ec11bc3bd3113",
            dev_x64_ts = "e220b9838f84b9fa9149ca7cd73c87ae88fe2a460cb0de782c58f43ead57f80e",
            dev_x86_nts = "56bf71b28cb076fb2fa21e1a6fabacf05edef018803a6c52f5b30610cf4e3923",
            dev_x86_ts = "01d0a444ab4215d438e779d9330d665f63fc05a3fd7082b210f465df37e886a9"
        }
    },
    ["8.4.21"] = {
        source = "4e7baaf0a690e954a20e7ced3dd633ce8cb8094e2b6b612a55e703ecbbdcbf4f",
        win = {
            x64_nts = "2cb57d0d3a17b1248c6a53b600719d4b051e1c374373404d5031409c0725031d",
            x64_ts = "9e2f6e455d3f42993f09deed23ad0178b3787090c924793e50414b6a92de186a",
            debug_x64_nts = "55df4d98b63a47150aa2f7b3a4ee2f6a9e528dbb29edae63e19476e02fc04be0",
            debug_x64_ts = "ee10f63e5d327022ce027fdfd495f2819a56b5a571bad783bb9924db94f84604",
            x86_nts = "99c9827d01480147e735e443e2ffe6f1974af053e521f63a46d1a498d2a45d13",
            x86_ts = "83a472c6ecc3c6a5c607e1b96a307f19daa6c1745eb6cc6ebb601db4cd49f514",
            debug_x86_nts = "c948abbef7588bd5ae50ada25666e64d80d8186d26fc3871fc2cc1a315648d1d",
            debug_x86_ts = "2e462b08077bd993926fb7670bdbf4d9bcff66ceff8f51a3790e20b57d107cf0",
            dev_x64_nts = "9e8987e555089df31bb79452fa4729ab93fb8433269b14ca194ddd891b0512d7",
            dev_x64_ts = "70e4d2566cfbaf2f627e7e9c8c55eda4ada66ad2af47f68c0e7964654f645d96",
            dev_x86_nts = "0c8fb7a648175e64ceba33525e1bcd0a49f44dce4cbcc864399b15e19ae1c5f2",
            dev_x86_ts = "aa734f398b2ebb02cdf368467dbaaad49d93cc31ed01338bf62c98a07df42e14"
        }
    },
    ["8.3.31"] = {
        source = "4e7baaf0a690e954a20e7ced3dd633ce8cb8094e2b6b612a55e703ecbbdcbf4f",
        win = {
            x64_nts = "389c1327d325f6b6b3b892a5b2e1484ca5b5df775b6c4ddf5d1b5dc3b34ac761",
            x64_ts = "d223892e2ea4b4bfbef06391bd0937c1a52a8ec66b16732d61f26189b124a887",
            debug_x64_nts = "02209ffcb1bbe7c55c84605b13fcc69f400602a0660ad5a7f6d3523e505227cf",
            debug_x64_ts = "f517cabce829015d64eb499cb560e73a523ea27c35ce7aa21d4ec12ad7648fea",
            x86_nts = "c49a3d1d5daeb8ea32c48bbc2b0533ebb8cf54d8273b9a3b83323e1e55e15480",
            x86_ts = "f9e0d9745fd81f5edb12f11896de9f4afaa291acb3638107513cb9fc69b25d9e",
            debug_x86_nts = "956935ea0d86b6e6c371b60797b23d7d262ba8a44aeab0850f49df84fe5fbc4d",
            debug_x86_ts = "89e5193a918cb7cb9b97f2b7c70556fb321237cf0602e71c32db09b0b3d27565",
            dev_x64_nts = "ff596d5061afea9017d861be3d16a78fb5b838d7077d40309e5624b3ba0e295a",
            dev_x64_ts = "d370049affe0a0da16adf173e6b49e37949768411428d572f4b7a4e519cf4421",
            dev_x86_nts = "9de07d2735a742147fe195ea2966876732aa77b2bfdbc8425a671a9f061c380f",
            dev_x86_ts = "02ba816a275328a838b072217c8aba9d6726d857ea1d31235c517bdfe8c8ee6a"
        }
    }
}
