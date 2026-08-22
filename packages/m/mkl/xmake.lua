package("mkl")

    set_homepage("https://software.intel.com/content/www/us/en/develop/tools/oneapi/components/onemkl.html")
    set_description("Intel® oneAPI Math Kernel Library")

    if is_plat("windows") then
        if is_arch("x64") then
            add_urls("https://software.repos.intel.com/python/conda/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("win-64/mkl-static-%s-intel_%s", mv[1], mv[2])
            end})
            add_urls("https://software.repos.intel.com/python/conda/$(version).conda", {alias = "conda", version = function (version)
                local mv = version:split("%+")
                return format("win-64/mkl-static-%s-intel_%s", mv[1], mv[2])
            end})
            add_versions("2022.2.0+9563", "82ed56af423fa6f2fef46085e267695feb5fd079a5eabb6353a99598ff2a7879")
            add_resources("2022.2.0+9563", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2022.2.0-intel_9563.tar.bz2", "da4458b2c8f86b7e8d2772e1d992b8913dd74fb9d0822559eb9538aa36125a45")
            add_versions("2022.2.1+19754", "a1c3592caeb248ec16698d2a0971b6c6fa8eae1ddfd0cc575d8ec1d02e607ee6")
            add_resources("2022.2.1+19754", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2022.2.1-intel_19754.tar.bz2", "675519d77dfbf38bfa3dd94f37d3d1fa9f74b32f089e50123605ff3d45752c44")
            add_versions("2023.2.0+49496", "21a9fe03ba80009934a50b9d75f16757b9e49415e44245ced3b896fd471351ca")
            add_resources("2023.2.0+49496", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2023.2.0-intel_49496.tar.bz2", "daa93c899e6c7627232fa60e67a2b6079cd29752e8ba1251ae895a57e51defa7")
            add_versions("2024.1.0+692", "6431647057cd8757a464a3f6ab2099139e059d04446f04443afd2570febe42bf")
            add_resources("2024.1.0+692", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2024.1.0-intel_692.tar.bz2", "28229844aa6c19870531452e5805ab876da4a5df896a9e753e6b481da2d389cb")
            add_versions("2024.2.0+661", "e760103a484d5132f0af35e58ccad7b576536d38744141e776f3ad1673adc455")
            add_resources("2024.2.0+661", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2024.2.0-intel_661.tar.bz2", "34f5cc20b6d2ab7c82f301b108fa2ac48e1f6c0acd8ad166897fb53184d5c93e")
            add_versions("2024.2.1+102", "fa0767ee84e93f59fd4ae92434a1110cd0830b254229b9ffdce36c60adebd574")
            add_resources("2024.2.1+102", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2024.2.1-intel_102.tar.bz2", "54f362cbb74c9cb787e76248e30910316b24dfda273d872149b3f2ecb5893057")
            add_versions("2024.2.2+14", "b80676e8fa65e5e5d82cfc6759ea2a61088bddf3ab144161bf2323ec8fe474c3")
            add_resources("2024.2.2+14", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2024.2.2-intel_14.tar.bz2", "06b8cba21654bb21f6d535d6757c805e93330f11dc7dc5eaa55e926be9e20c4b")
            add_versions("2025.0.0+928", "27b648f7420621b73b0b54394caa0facaf1c8c720748e3a9085398a48ff17e17")
            add_resources("2025.0.0+928", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2025.0.0-intel_928.tar.bz2", "49c9e263a3a3cb2a6929900bfa66a19449cdaeee2da8a821aa8aa7e2fbaf9240")
            add_versions("2025.0.1+5", "799d83e6d4474d52bcbee61b5697f0b32a7993b335c5cee504a0fb9e97e9b65a")
            add_resources("2025.0.1+5", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2025.0.1-intel_5.tar.bz2", "2492bf11b16bf9b911d65398bbca4f848b7b3b344a483b132a6a5aa68ff3d95c")
            add_versions("conda:2025.1.0+798", "e7e905c58aae00b6497c3feb2208bdd83700293160703ca4371896c3a692ac93")
            add_resources("2025.1.0+798", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2025.1.0-intel_798.conda", "95f4cb0304186d6638f0033628b802d32791ba907198e32715c156f369ff67cc")
            add_versions("conda:2025.2.0+627", "cbd5bcda7bd9882c851a9d6358303957c0a8fe047d994af545a20be70558f386")
            add_resources("2025.2.0+627", "headers", "https://software.repos.intel.com/python/conda/win-64/mkl-include-2025.2.0-intel_627.conda", "c13f5c8fde02698d4780c15e7fa4d39b1055ac7505628e82b699bc18f86a8a4e")
        elseif is_arch("x86") then
            add_urls("https://software.repos.intel.com/python/conda/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("win-32/mkl-static-%s-intel_%s", mv[1], mv[2])
            end})
            add_versions("2022.2.0+9563", "2cf2098ce3f6c14f1c86c850a6c4f5519966f6a70589ac4bf4cb0013b575f282")
            add_resources("2022.2.0+9563", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2022.2.0-intel_9563.tar.bz2", "4b05540349b3aaa55e5b0e3b51d4286649ae76b1c1d763a56ffcdad1bb927bf9")
            add_versions("2022.2.1+19754", "b663b6916996d7b090ef4a8c1d270b9a1a84b1bdefe85cc01e778f8e629b7a6c")
            add_resources("2022.2.1+19754", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2022.2.1-intel_19754.tar.bz2", "04c3ce3f1e6e23e575f904fbdafd089f3241bf28ca1005b2464d87795295dc50")
            add_versions("2023.2.0+49496", "4795b6a00b1b7ae5c608de67ba2c79ad152223d0eaf4aba46db848bbae268718")
            add_resources("2023.2.0+49496", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2023.2.0-intel_49496.tar.bz2", "0ed907ecc2eaae0ed8c280814392b5b80cc19df78838d9688273a12bd72c7bf8")
            add_versions("2024.1.0+692", "7a8622f23a27fa487f08653645b6dc3f46b10f5b60ea2b90377812571730d0d9")
            add_resources("2024.1.0+692", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2024.1.0-intel_692.tar.bz2", "8994e1c5b5599934e83eb964a136be98dc5a6355f3f5b35cab44cdc0e8b970dd")
            add_versions("2024.2.0+661", "0a126754b76cf41e9fbc10e7cb70d69018059a2a413560938184b7886bced28b")
            add_resources("2024.2.0+661", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2024.2.0-intel_661.tar.bz2", "431feac62519a0d65c85e801d7329cb7caa66ced53a0b4d26f15420d06d1717d")
            add_versions("2024.2.1+102", "133b0d10a1225293742a6355c08752a8d6c9ef1ec744be8ed60b92d035558006")
            add_resources("2024.2.1+102", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2024.2.1-intel_102.tar.bz2", "ac7bc36bd84a144c03ba44f4f146caa91af549a3ddcf302513b3ed75dd0a153e")
            add_versions("2024.2.2+14", "bcfb0170aa7bac9bd633b9d8965b3e4b3633802bb537165f22db7c7a15f70ead")
            add_resources("2024.2.2+14", "headers", "https://software.repos.intel.com/python/conda/win-32/mkl-include-2024.2.2-intel_14.tar.bz2", "81e1cc1960b10626f0c2209e21bf013bf4bf8cfc4a1ba38b2301d20aa0e1d6d6")
        end
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://software.repos.intel.com/python/conda/$(version).tar.bz2", {version = function (version)
            local mv = version:split("%+")
            return format("osx-64/mkl-static-%s-intel_%s", mv[1], mv[2])
        end})
        add_versions("2022.2.0+8687", "cd5ecb73ec922d2b8ae6e06f6caa0549113911f76b2eac1969566a8edb92c301")
        add_resources("2022.2.0+8687", "headers", "https://software.repos.intel.com/python/conda/osx-64/mkl-include-2022.2.0-intel_8687.tar.bz2", "2efc298a72ef7e49ba6142055352666c261ca592a3d5779e62a012334bf52a6b")
        add_versions("2022.2.1+15346", "bce4e4d72117242c2a3cf75fcac134e7c3baabf7334003ec0f377ab7123ce30d")
        add_resources("2022.2.1+15346", "headers", "https://software.repos.intel.com/python/conda/osx-64/mkl-include-2022.2.1-intel_15346.tar.bz2", "fa14e44b3adbcc156aa7b531c4e83143cf9d31fe990210cb6d5d5456f8a417a8")
        add_versions("2023.2.0+49499", "2e2f6bd275e439f82f081e28e774dec663718b199a696da635934536a51faa73")
        add_resources("2023.2.0+49499", "headers", "https://software.repos.intel.com/python/conda/osx-64/mkl-include-2023.2.0-intel_49499.tar.bz2", "c3940a33498df821821c28dc292f7d7a739b11892856fd9fbbc3de5cf0990b00")
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            add_urls("https://software.repos.intel.com/python/conda/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("linux-64/mkl-static-%s-intel_%s", mv[1], mv[2])
            end})
            add_urls("https://software.repos.intel.com/python/conda/$(version).conda", {alias = "conda", version = function (version)
                local mv = version:split("%+")
                return format("linux-64/mkl-static-%s-intel_%s", mv[1], mv[2])
            end})
            add_versions("2022.2.0+8748", "cbcff4024be9830a9fb7f640d4555ea4f3a9c4dd503df67a42f11b940286b7b3")
            add_resources("2022.2.0+8748", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2022.2.0-intel_8748.tar.bz2", "9dd06c499ec890294b2909a0784303e94b14d88c6e95ae4ffee308f16fd55121")
            add_versions("2022.2.1+16993", "4f1e738b7b54763a211b52702dea763d1c5dff352cb14a6155244634b58b28f9")
            add_resources("2022.2.1+16993", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2022.2.1-intel_16993.tar.bz2", "144b4939c875ae52b5479317e73be839f5b26b3b0e2c3a52bd59507bc25be56c")
            add_versions("2024.1.0+691", "be8833b094253d51abe49de418f7db2260f4c8f32514969a4a2eabaadc5d55c2")
            add_resources("2024.1.0+691", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2024.1.0-intel_691.tar.bz2", "e36b2e74f5c28ff91565abe47a09dc246c9cf725e0d05b5fb08813b4073ea68b")
            add_versions("2024.2.0+663", "7ee44680030cf187c430a34051ccf37a2c697ad82b62fb0508dfe7a94d7e27f7")
            add_resources("2024.2.0+663", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2024.2.0-intel_663.tar.bz2", "2e29ca36f199bafed778230b054256593c2d572aeb050389fd87355ba0466d13")
            add_versions("2024.2.1+103", "cde63703ea42627c50ad6dfb3ec336e18fa957964d40e5472783d82c461c083a")
            add_resources("2024.2.1+103", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2024.2.1-intel_103.tar.bz2", "df19cbc68fda9e125445df8ea94a7af2c6a8cb009193104741c9f2d1223de193")
            add_versions("2024.2.2+15", "5dc0f934f4a8dbb8e297f5f57b4e069fd71cbb87c4e3225f12670f802b246b3a")
            add_resources("2024.2.2+15", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2024.2.2-intel_15.tar.bz2", "a64890440a9155104472f32a6c83215386edfd26b6a5a881548a74f3a2e65981")
            add_versions("2025.0.0+939", "2c27e4a7dab877a60f749a79986f499a7d3db2eea39c25d3c516622f3d34c22f")
            add_resources("2025.0.0+939", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2025.0.0-intel_939.tar.bz2", "e3c02344b0405d90c7b992493a081f1f763fa96493626a5da1fe7693040a486f")
            add_versions("2025.0.1+14", "aa1e600d0c26b4fe7960bae84489162efbd03ee76c1fa2865630f9303768bdbe")
            add_resources("2025.0.1+14", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2025.0.1-intel_14.tar.bz2", "a8cef2bc84c135a38031f3bb5b0ec1c42cbb8e8e969754f91c25d50a19fda22b")
            add_versions("conda:2025.1.0+801", "9edb8ef62d24646506dd2afc8160ea84ff9c9add8c63cbbd420d63283a16a541")
            add_resources("2025.1.0+801", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2025.1.0-intel_801.conda", "ccf54c873bb7527dc1aab08e7ab731e89d399c09f4cd94db374807a7d78f7902")
            add_versions("conda:2025.2.0+628", "8300e658101009976eab63789b6a01b8bad20ff3bd27692e1d5324e4b8f78df1")
            add_resources("2025.2.0+628", "headers", "https://software.repos.intel.com/python/conda/linux-64/mkl-include-2025.2.0-intel_628.conda", "b8485a410756687dae93c2b83f58a01bf38e94c32279d845f72e8c0d60de83ab")
        elseif is_arch("i386") then
            add_urls("https://software.repos.intel.com/python/conda/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("linux-32/mkl-static-%s-intel_%s", mv[1], mv[2])
            end})
            add_versions("2022.2.0+8748", "af6b8cb0a6b61a97c6048bf57c5e807ff7052e845da69078f992671e393262a6")
            add_resources("2022.2.0+8748", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2022.2.0-intel_8748.tar.bz2", "64f7d55059d0d85e0a88507304a54356ec9713f5dee1b205462aa0f97b0f6683")
            add_versions("2022.2.1+16993", "e588ea2583d2e5cbf072574531610cf0acae8490dc4432b41a9f3ddb5e67dece")
            add_resources("2022.2.1+16993", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2022.2.1-intel_16993.tar.bz2", "2deec097b972d7784b26b454169af302a0d4e26cc1d65cbb4ed72baf00a8849e")
            add_versions("2023.2.0+49495", "9cdcb26ebbbe1510611f01f75780c0e69522d5df73395370a73c81413beaa56a")
            add_resources("2023.2.0+49495", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2023.2.0-intel_49495.tar.bz2", "b4433c6839bb7f48951b2dcf409dec7306aee3649c539ee0513d8bfb1a1ea283")
            add_versions("2024.1.0+691", "8bd52f73844edc59fe925fa9edef66a7158e502df7c06ddc532d1b370df4fb7d")
            add_resources("2024.1.0+691", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2024.1.0-intel_691.tar.bz2", "88529f8bea2498e88b2cf8dc7aa3735f46f348cf5047006dfc6455f8e2bbdd30")
            add_versions("2024.2.0+663", "505eea9981643dac10f342eca80603982365f6b598e6435e07c9d5385622f578")
            add_resources("2024.2.0+663", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2024.2.0-intel_663.tar.bz2", "d97e655707590ba38d1240a4f9be3f60df2bc82f3ab5f7b16cf2735d4d9ba401")
            add_versions("2024.2.1+103", "def6c66abfcefd2d9cb0ed32a2d4bd2b4961ef4e5f5f72a4c699fd63456fc959")
            add_resources("2024.2.1+103", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2024.2.1-intel_103.tar.bz2", "4595375b6b04847721f84a88122089fa4a9d28a4d26afe89d44334c6edf56e84")
            add_versions("2024.2.2+15", "47207da3090687f1ca042a09cfff3c39e0bb63093eb9319afc1694ce9f33bc56")
            add_resources("2024.2.2+15", "headers", "https://software.repos.intel.com/python/conda/linux-32/mkl-include-2024.2.2-intel_15.tar.bz2", "347cf16676df797ddcba3a4289c7dc64624138583ba35f0c63d0a19b48c89596")
        end
    end

    add_configs("threading", {description = "Choose threading modal for mkl.", default = "tbb", type = "string", values = {"tbb", "openmp", "gomp", "seq"}})
    add_configs("interface", {description = "Choose index integer size for the interface.", default = 32, values = {32, 64}})

    on_fetch("fetch")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    add_deps("zstd", {private = true, kind = "binary"})
    on_load(function (package)
        -- Refer to [oneAPI Math Kernel Library Link Line Advisor](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-link-line-advisor.html)
        -- to get the link option for MKL library.
        local suffix = (package:config("interface") == 32 and "lp64" or "ilp64")
        if package:config("interface") == 64 then
            package:add("defines", "MKL_ILP64")
        end
        package:add("links", package:is_arch("x64", "x86_64") and "mkl_blas95_" .. suffix or "mkl_blas95")
        package:add("links", package:is_arch("x64", "x86_64") and "mkl_lapack95_" .. suffix or "mkl_lapack95")

        if package:has_tool("cc", "gcc", "gxx") then
            local flags = {"-Wl,--start-group"}
            table.insert(flags, package:is_arch("x64", "x86_64") and "-lmkl_intel_" .. suffix or "-lmkl_intel")
            local threading = package:config("threading")
            if threading == "tbb" then
                table.insert(flags, "-lmkl_tbb_thread")
                package:add("deps", "tbb")
            elseif threading == "seq" then
                table.insert(flags, "-lmkl_sequential")
            elseif threading == "openmp" then
                table.insert(flags, "-lmkl_intel_thread")
                table.insert(flags, "-lomp")
            elseif threading == "gomp" then
                table.insert(flags, "-lmkl_gnu_thread")
                table.insert(flags, "-lgomp")
            end
            table.insert(flags, "-lmkl_core")
            table.insert(flags, "-Wl,--end-group")
            package:add("ldflags", table.concat(flags, " "))
        else
            package:add("links", package:is_arch("x64", "x86_64") and "mkl_intel_" .. suffix or "mkl_intel_c")
            local threading = package:config("threading")
            if threading == "tbb" then
                package:add("links", "mkl_tbb_thread")
                package:add("deps", "tbb")
            elseif threading == "seq" then
                package:add("links", "mkl_sequential")
            elseif threading == "openmp" then
                package:add("links", "mkl_intel_thread", "omp")
            elseif threading == "gomp" then
                package:add("links", "mkl_gnu_thread", "gomp")
            end
            package:add("links", "mkl_core")
        end
    end)

    on_install("windows|!arm64", "macosx|!arm64", "linux|x86_64", "linux|i386", function (package)
        import("lib.detect.find_tool")
        local headerdir = package:resourcedir("headers")
        -- Only proceed if library files don't already exist
        if not (os.exists("lib") or os.exists("Library")) then
            -- Get version components for filename construction
            local mv = package:version():split("%+")
            local lib_filename = format("mkl-static-%s-intel_%s", mv[1], mv[2])
            local inc_filename = format("mkl-include-%s-intel_%s", mv[1], mv[2])
            -- Find required tools
            local z7 = assert(find_tool("7z"), "7z tool not found!")
            local zstd = assert(find_tool("zstd"), "zstd tool not found!")
            -- Helper function to extract .conda -> .tar.zst -> .tar -> files
            local function extract_conda(conda_file)
                -- .conda -> .tar.zst
                os.vrunv(z7.program, {"x", "-y", conda_file})
                local archivefile = "pkg-" .. path.basename(conda_file) .. ".tar.zst"
                -- .tar.zst -> .tar
                local temp_tar = os.tmpfile() .. ".tar"
                os.vrunv(zstd.program, {"-d", "-q", "-o", temp_tar, archivefile})
                -- .tar -> files
                os.vrunv(z7.program, {"x", "-y", temp_tar})
                -- Clean up temporary files
                os.tryrm(temp_tar)
                os.tryrm(archivefile)
            end
            -- support for xmake 3.0.2
            os.trycp(
                format("../%s-%s.conda", package:name(), package:version_str()),
                format("../%s.conda", lib_filename)
            )
            os.trycp("../" .. package:name() .. "-" .. package:version_str(), "../" .. lib_filename .. ".conda")
            -- Process library files
            extract_conda("../" .. lib_filename .. ".conda")
            -- Process header files
            extract_conda(path.join(headerdir, "../" .. inc_filename .. ".conda"))
            -- Move headers to the correct location
            if package:is_plat("windows") then
                os.trymv("Library/include", path.join(headerdir, "Library", "include"))
            else
                os.trymv("include", headerdir)
            end
            -- Clean up remaining temporary files
            os.tryrm("pkg-" .. lib_filename .. ".tar")
            os.tryrm("pkg-" .. inc_filename .. ".tar")
        end

        if package:is_plat("windows") then
            os.trymv(path.join("Library", "lib"), package:installdir())
            os.trymv(path.join(headerdir, "Library", "include"), package:installdir())
        else
            os.trymv(path.join("lib"), package:installdir())
            os.trymv(path.join(headerdir, "include"), package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                double A[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double B[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double C[9] = {.5,.5,.5,.5,.5,.5,.5,.5,.5};
                cblas_dgemm(CblasColMajor,CblasNoTrans,CblasTrans,3,3,2,1,A,3,B,3,2,C,3);
            }
        ]]}, {includes = "mkl_cblas.h"}))
    end)
