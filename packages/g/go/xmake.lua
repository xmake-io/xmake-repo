package("go")
    set_kind("binary")
    set_homepage("https://go.dev")
    set_description("The Go Programming Language")
    set_license("BSD-3-Clause")

    if is_host("windows") then
        if os.arch() == "x64" then
            set_urls("https://go.dev/dl/go$(version).windows-amd64.zip")
            add_versions("1.22.6", "6023083a6e4d3199b44c37e9ba7b25d9674da20fd846a35ee5f9589d81c21a6a")
            add_versions("1.22.7", "efbc30520601f4d91d9f3f46af03aafb2e1428388c5ff6a40eb88489f7212e85")
            add_versions("1.22.8", "9eca39a677c6d055ed947087c63e430b2c6d5dd0dd84636cb171fa2717451ee1")
            add_versions("1.22.9", "2b7480239dc42867761c51ba653d8190ac55e99b41b0ff751224f87984c8421b")
            add_versions("1.22.10", "da66f107a0f4959f4615bede230c6bf145a6f01252c6d1ff2b107e293ba339df")
            add_versions("1.22.11", "4542e3967b2595286885dd83bae417b8ecfd058af4a7544fe4b138eb8a93a5e7")
            add_versions("1.22.12", "2ceda04074eac51f4b0b85a9fcca38bcd49daee24bed9ea1f29958a8e22673a6")
            add_versions("1.23.0", "d4be481ef73079ee0ad46081d278923aa3fd78db1b3cf147172592f73e14c1ac")
            add_versions("1.23.1", "32dedf277c86610e380e1765593edb66876f00223df71690bd6be68ee17675c0")
            add_versions("1.23.2", "bc28fe3002cd65cec65d0e4f6000584dacb8c71bfaff8801dfb532855ca42513")
            add_versions("1.23.3", "81968b563642096b8a7521171e2be6e77ff6f44032f7493b7bdec9d33f44f31d")
            add_versions("1.23.4", "16c59ac9196b63afb872ce9b47f945b9821a3e1542ec125f16f6085a1c0f3c39")
            add_versions("1.23.5", "96d74945d7daeeb98a7978d0cf099321d7eb821b45f5c510373d545162d39c20")
            add_versions("1.23.6", "53fec1586850b2cf5ad6438341ff7adc5f6700dd3ec1cfa3f5e8b141df190243")
            add_versions("1.23.7", "eba0477381037868738b47b0198d120a535eb9a8a17b2babb9ab0d5e912a2171")
            add_versions("1.23.8", "e0ad643f94875403830e84198dc9df6149647c924bfa91521f6eb29f4c013dc7")
            add_versions("1.24.0", "96b7280979205813759ee6947be7e3bb497da85c482711116c00522e3bb41ff1")
            add_versions("1.24.1", "95666b551453209a2b8869d29d177285ff9573af10f085d961d7ae5440f645ce")
            add_versions("1.24.2", "29c553aabee0743e2ffa3e9fa0cda00ef3b3cc4ff0bc92007f31f80fd69892e1")
        elseif os.arch() == "arm64" then
            set_urls("https://go.dev/dl/go$(version).windows-arm64.zip")
            add_versions("1.22.6", "7cf55f357ba8116cd3bff992980e20a704ba451b3dab341cf1787b133d900512")
            add_versions("1.22.7", "9007bdda31f22176a8f686aa52c406e144e8e88f5133a8baddadd5129ede1165")
            add_versions("1.22.8", "cede70578fa92664e9960b391174c520c8f9ad593adfa0d3bcab5e45f9180169")
            add_versions("1.22.9", "7fc98e9f11d7a7255d9314a70bdb36f15fc65d70e3f4a6d3fb8ea9ceb4289fd6")
            add_versions("1.22.10", "974656452fd7d104f34ee6e8ac92bb7431af84a1ce55226d9af485cb9ec23dd5")
            add_versions("1.22.11", "738bc531ff4a2b805611f51dc6b46dc10f5894f77e07c0783a1783ba31003f34")
            add_versions("1.22.12", "6b9eaf160b155e02ffe9ed603f162ecc3264f6130c8fcf83bb77087f9807fdec")
            add_versions("1.23.0", "0be62073ef8f5a2d3b9adcefddf18c417dab0a7975c71488ac2694856e2ff976")
            add_versions("1.23.1", "64ad0954d2c33f556fb1018d62de091254aa6e3a94f1c8a8b16af0d3701d194e")
            add_versions("1.23.2", "0d50bade977b84e173cb350946087f5de8c75f8df19456c3b60c5d58e186089d")
            add_versions("1.23.3", "dbdfa868b1a3f8c62950373e4975d83f90dd8b869a3907319af8384919bcaffe")
            add_versions("1.23.4", "db69cae5006753c785345c3215ad941f8b6224e2f81fec471c42d6857bee0e6f")
            add_versions("1.23.5", "4f20c2d8a5a387c227e3ef48c5506b22906139d8afd8d66a78ef3de8dda1d1c3")
            add_versions("1.23.6", "a2d2ec1b3759552bdd9cdf58858f91dfbfd6ab3a472f00b5255acbed30b1aa41")
            add_versions("1.23.7", "e828b5c526c40f3fa6f8aea2d402c0fcbf064009f2d0d12a15bb01241255af9a")
            add_versions("1.23.8", "9adfac04871d3db381f2c852679ba9a3f8260fe5fb66a50a74c184ee0e9cba95")
            add_versions("1.24.0", "53f73450fb66075d16be9f206e9177bd972b528168271918c4747903b5596c3d")
            add_versions("1.24.1", "e28c4e6d0b913955765b46157ab88ae59bb636acaa12d7bec959aa6900f1cebd")
            add_versions("1.24.2", "ab267f7f9a3366d48d7664be9e627ce3e63273231430cce5f7783fb910f14148")
        else
            set_urls("https://go.dev/dl/go$(version).windows-386.zip")
            add_versions("1.22.6", "eb734bacc9aabca1273b61dd392bb84a9bb33783f5e2fff2cd6ab9885bbefbe6")
            add_versions("1.22.7", "5077c4a2c8a398817caa3178785abac5a93109173a488ae289d697544aac9cde")
            add_versions("1.22.8", "94dfb97846276a214f72670be2f5604b7f0557057c9d5f522780fe266ffab9e9")
            add_versions("1.22.9", "2a9f949b327880d759b9f071d5e28d1ebe028534ebf63cce7460a27ee2db7ad6")
            add_versions("1.22.10", "20019b2e60dd0cdf63e4ec26852c1c015c1a27580b32a512b4be33a2539113ae")
            add_versions("1.22.11", "66c7adcd8bba00a7c7ebe88ad2d5f5a035c7a4b2a41ab563f18017cf1471b18e")
            add_versions("1.22.12", "9ab2e2f8bede9be98d63457f0a65d62387baa8b3f9e11af3e9a0a9eef2abf435")
            add_versions("1.23.0", "09448fedec0cdf98ad12397222e0c8bfc835b1d0894c0015ced653534b8d7427")
            add_versions("1.23.1", "ab866f47d7be56e6b1c67f1d529bf4c23331a339fb0785f435a0552d352cb257")
            add_versions("1.23.2", "eaa3bc377badbdcae144633f8b29bf2680475b72dcd4c135343d3bdc0ba7671e")
            add_versions("1.23.3", "23da9089ea6c5612d718f13c26e9bfc9aaaabe222838075346a8191d48f9dfe5")
            add_versions("1.23.4", "e544e0e356147ba998e267002bd0f2c4bf3370d495467a55baf2c63595a2026d")
            add_versions("1.23.5", "8441605a005ea74c28d8c02ca5f2708c17b4df7e91796148b9f8760caafb05c1")
            add_versions("1.23.6", "96820c0f5d464dd694543329e9b4d413b17c821c03a055717a29e6735b44c2d8")
            add_versions("1.23.7", "c8587eaf0257d475bae5dd1d51530466a5e507dfa932d4f551acc3003e8bc1a8")
            add_versions("1.23.8", "9c58592da0f87dc66c23747d0cf75bbaf908c6fbfcf0570711d536a617b7ccbd")
            add_versions("1.24.0", "b53c28a4c2863ec50ab4a1dbebe818ef6177f86773b6f43475d40a5d9aa4ec9e")
            add_versions("1.24.1", "b799f4ab264eef12a014c759383ed934056608c483e0f73e34ea6caf9f1df5f9")
            add_versions("1.24.2", "13d86cb818bba331da75fcd18246ab31a1067b44fb4a243b6dfd93097eda7f37")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            set_urls("https://go.dev/dl/go$(version).linux-amd64.tar.gz")
            add_versions("1.22.6", "999805bed7d9039ec3da1a53bfbcafc13e367da52aa823cb60b68ba22d44c616")
            add_versions("1.22.7", "fc5d49b7a5035f1f1b265c17aa86e9819e6dc9af8260ad61430ee7fbe27881bb")
            add_versions("1.22.8", "5f467d29fc67c7ae6468cb6ad5b047a274bae8180cac5e0b7ddbfeba3e47e18f")
            add_versions("1.22.9", "84a8f05b7b969d8acfcaf194ce9298ad5d3ddbfc7034930c280006b5c85a574c")
            add_versions("1.22.10", "736ce492a19d756a92719a6121226087ccd91b652ed5caec40ad6dbfb2252092")
            add_versions("1.22.11", "0fc88d966d33896384fbde56e9a8d80a305dc17a9f48f1832e061724b1719991")
            add_versions("1.22.12", "4fa4f869b0f7fc6bb1eb2660e74657fbf04cdd290b5aef905585c86051b34d43")
            add_versions("1.23.0", "905a297f19ead44780548933e0ff1a1b86e8327bb459e92f9c0012569f76f5e3")
            add_versions("1.23.1", "49bbb517cfa9eee677e1e7897f7cf9cfdbcf49e05f61984a2789136de359f9bd")
            add_versions("1.23.2", "542d3c1705f1c6a1c5a80d5dc62e2e45171af291e755d591c5e6531ef63b454e")
            add_versions("1.23.3", "a0afb9744c00648bafb1b90b4aba5bdb86f424f02f9275399ce0c20b93a2c3a8")
            add_versions("1.23.4", "6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971")
            add_versions("1.23.5", "cbcad4a6482107c7c7926df1608106c189417163428200ce357695cc7e01d091")
            add_versions("1.23.6", "9379441ea310de000f33a4dc767bd966e72ab2826270e038e78b2c53c2e7802d")
            add_versions("1.23.7", "4741525e69841f2e22f9992af25df0c1112b07501f61f741c12c6389fcb119f3")
            add_versions("1.23.8", "45b87381172a58d62c977f27c4683c8681ef36580abecd14fd124d24ca306d3f")
            add_versions("1.24.0", "dea9ca38a0b852a74e81c26134671af7c0fbe65d81b0dc1c5bfe22cf7d4c8858")
            add_versions("1.24.1", "cb2396bae64183cdccf81a9a6df0aea3bce9511fc21469fb89a0c00470088073")
            add_versions("1.24.2", "68097bd680839cbc9d464a0edce4f7c333975e27a90246890e9f1078c7e702ad")
        elseif os.arch() == "i386" then
            set_urls("https://go.dev/dl/go$(version).linux-386.tar.gz")
            add_versions("1.22.6", "9e680027b058beab10ce5938607660964b6d2c564bf50bdb01aa090dc5beda98")
            add_versions("1.22.7", "810e4d9f3f2f03b2f11471a9c7a32302968fc09d51f666cecacedb1055f2f873")
            add_versions("1.22.8", "0c8e9f824bf443f51e06ac017b9ae402ea066d761b309d880dbb2ca5793db8a2")
            add_versions("1.22.9", "bd70967c67b52f446596687dbe7f3f057a661d32e4d5f6658f1353ae7bb8f676")
            add_versions("1.22.10", "2ae9f00e9621489b75494fa2b8abfc5d09e0cae6effdd4c13867957ad2e4deba")
            add_versions("1.22.11", "b40ee463437e8c8f2d6c9685a0e166eaecb36615afa362eaa58459d3369f3baf")
            add_versions("1.22.12", "40d4c297bc2e964e9c96fe79bb323dce79b77b8b103fc7cc52e0a87c7849890f")
            add_versions("1.23.0", "0e8a7340c2632e6fb5088d60f95b52be1f8303143e04cd34e9b2314fafc24edd")
            add_versions("1.23.1", "cdee2f4e2efa001f7ee75c90f2efc310b63346cfbba7b549987e9139527c6b17")
            add_versions("1.23.2", "cb1ed4410f68d8be1156cee0a74fcfbdcd9bca377c83db3a9e1b07eebc6d71ef")
            add_versions("1.23.3", "3d7b00191a43c50d28e0903a0c576104bc7e171a8670de419d41111c08dfa299")
            add_versions("1.23.4", "4a4a0e7587ef8c8a326439b957027f2791795e2d29d4ae3885b4091a48f843bc")
            add_versions("1.23.5", "6ecf6a41d0925358905fa2641db0e1c9037aa5b5bcd26ca6734caf50d9196417")
            add_versions("1.23.6", "e61f87693169c0bbcc43363128f1e929b9dff0b7f448573f1bdd4e4a0b9687ba")
            add_versions("1.23.7", "9115f7d751efe5b17b63a7630d24cd0a2479976465eecb277b5deec8aa0f4143")
            add_versions("1.23.8", "714b9d004063bfa27686f9ff0e5648bb190b3a5bc1e86b0aa16c134d8d8c315f")
            add_versions("1.24.0", "90521453a59c6ce20364d2dc7c38532949b033b602ba12d782caeb90af1b0624")
            add_versions("1.24.1", "8c530ecedbc17e42ce10177bea07ccc96a3e77c792ea1ea72173a9675d16ffa5")
            add_versions("1.24.2", "4c382776d52313266f3026236297a224a6688751256a2dffa3f524d8d6f6c0ba")
        elseif os.arch() == "arm64" then
            set_urls("https://go.dev/dl/go$(version).linux-arm64.tar.gz")
            add_versions("1.22.6", "c15fa895341b8eaf7f219fada25c36a610eb042985dc1a912410c1c90098eaf2")
            add_versions("1.22.7", "ed695684438facbd7e0f286c30b7bc2411cfc605516d8127dc25c62fe5b03885")
            add_versions("1.22.8", "5c616b32dab04bb8c4c8700478381daea0174dc70083e4026321163879278a4a")
            add_versions("1.22.9", "5beec5ef9f019e1779727ef0d9643fa8bf2495e7222014d2fc4fbfce5999bf01")
            add_versions("1.22.10", "5213c5e32fde3bd7da65516467b7ffbfe40d2bb5a5f58105e387eef450583eec")
            add_versions("1.22.11", "9ebfcab26801fa4cf0627c6439db7a4da4d3c6766142a3dd83508240e4f21031")
            add_versions("1.22.12", "fd017e647ec28525e86ae8203236e0653242722a7436929b1f775744e26278e7")
            add_versions("1.23.0", "62788056693009bcf7020eedc778cdd1781941c6145eab7688bd087bce0f8659")
            add_versions("1.23.1", "faec7f7f8ae53fda0f3d408f52182d942cc89ef5b7d3d9f23ff117437d4b2d2f")
            add_versions("1.23.2", "f626cdd92fc21a88b31c1251f419c17782933a42903db87a174ce74eeecc66a9")
            add_versions("1.23.3", "1f7cbd7f668ea32a107ecd41b6488aaee1f5d77a66efd885b175494439d4e1ce")
            add_versions("1.23.4", "16e5017863a7f6071363782b1b8042eb12c6ca4f4cd71528b2123f0a1275b13e")
            add_versions("1.23.5", "47c84d332123883653b70da2db7dd57d2a865921ba4724efcdf56b5da7021db0")
            add_versions("1.23.6", "561c780e8f4a8955d32bf72e46af0b5ee5e0debe1e4633df9a03781878219202")
            add_versions("1.23.7", "597acbd0505250d4d98c4c83adf201562a8c812cbcd7b341689a07087a87a541")
            add_versions("1.23.8", "9d6d938422724a954832d6f806d397cf85ccfde8c581c201673e50e634fdc992")
            add_versions("1.24.0", "c3fa6d16ffa261091a5617145553c71d21435ce547e44cc6dfb7470865527cc7")
            add_versions("1.24.1", "8df5750ffc0281017fb6070fba450f5d22b600a02081dceef47966ffaf36a3af")
            add_versions("1.24.2", "756274ea4b68fa5535eb9fe2559889287d725a8da63c6aae4d5f23778c229f4b")
        end
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            set_urls("https://go.dev/dl/go$(version).darwin-amd64.tar.gz")
            add_versions("1.22.6", "9c3c0124b01b5365f73a1489649f78f971ecf84844ad9ca58fde133096ddb61b")
            add_versions("1.22.7", "2c1b36bf4a21dabe3f23384c8228804c9af4c233de6250ec2e69249c25d15070")
            add_versions("1.22.8", "ef0f7c1da5c8ac1eed0361381591a55effc90f9ca63b12cfd319f3f8ee113c12")
            add_versions("1.22.9", "41ba7acea4140e14dc88c77a9ed0a8d702c95bdfaf8b6e8508a92f3dc559fe7f")
            add_versions("1.22.10", "dd2c4ac3702658c2c20e3a8b394da1917d86156b2cb4312c9d2f657f80067874")
            add_versions("1.22.11", "c6d130066d509ccca1164d84514905b1e8dc5f5f4c25c24113f1b65ad87cd020")
            add_versions("1.22.12", "e7bbe07e96f0bd3df04225090fe1e7852ed33af37c43a23e16edbbb3b90a5b7c")
            add_versions("1.23.0", "ffd070acf59f054e8691b838f274d540572db0bd09654af851e4e76ab88403dc")
            add_versions("1.23.1", "488d9e4ca3e3ed513ee4edd91bef3a2360c65fa6d6be59cf79640bf840130a58")
            add_versions("1.23.2", "445c0ef19d8692283f4c3a92052cc0568f5a048f4e546105f58e991d4aea54f5")
            add_versions("1.23.3", "c7e024d5c0bc81845070f23598caf02f05b8ae88fd4ad2cd3e236ddbea833ad2")
            add_versions("1.23.4", "6700067389a53a1607d30aa8d6e01d198230397029faa0b109e89bc871ab5a0e")
            add_versions("1.23.5", "d8b310b0b6bd6a630307579165cfac8a37571483c7d6804a10dd73bbefb0827f")
            add_versions("1.23.6", "782da50ce8ec5e98fac2cd3cdc6a1d7130d093294fc310038f651444232a3fb0")
            add_versions("1.23.7", "3a3d6745286297cd011d2ab071998a85fe82714bf178dc3cd6ecd3d043a59270")
            add_versions("1.23.8", "4a0f0a5eb539013c1f4d989e0864aed45973c0a9d4b655ff9fd56013e74c1303")
            add_versions("1.24.0", "7af054e5088b68c24b3d6e135e5ca8d91bbd5a05cb7f7f0187367b3e6e9e05ee")
            add_versions("1.24.1", "addbfce2056744962e2d7436313ab93486660cf7a2e066d171b9d6f2da7c7abe")
            add_versions("1.24.2", "238d9c065d09ff6af229d2e3b8b5e85e688318d69f4006fb85a96e41c216ea83")
        elseif os.arch() == "arm64" then
            set_urls("https://go.dev/dl/go$(version).darwin-arm64.tar.gz")
            add_versions("1.22.6", "ebac39fd44fc22feed1bb519af431c84c55776e39b30f4fd62930da9c0cfd1e3")
            add_versions("1.22.7", "51a452563076950049da4857fb659437981ae70c7ec9bb0b0b2f1afc4dd66a9d")
            add_versions("1.22.8", "725bd8491bc302af9e7188b259db2f14dae6be4fb4f31965be4f76c9af84ff45")
            add_versions("1.22.9", "fc84ab2553ce05bcb41ddbe37b0a528083c770c10f9842ee6fb1f994bab2a842")
            add_versions("1.22.10", "21cf49415ffe0755b45f2b63e75d136528a32f7bb7bdd0166f51d22a03eb0a3f")
            add_versions("1.22.11", "3980b1d2be042a164989f2fd24f0bb306a2397d581a29c7426885578b369db5d")
            add_versions("1.22.12", "416c35218edb9d20990b5d8fc87be655d8b39926f15524ea35c66ee70273050d")
            add_versions("1.23.0", "b770812aef17d7b2ea406588e2b97689e9557aac7e646fe76218b216e2c51406")
            add_versions("1.23.1", "e223795ca340e285a760a6446ce57a74500b30e57469a4109961d36184d3c05a")
            add_versions("1.23.2", "d87031194fe3e01abdcaf3c7302148ade97a7add6eac3fec26765bcb3207b80f")
            add_versions("1.23.3", "31e119fe9bde6e105407a32558d5b5fa6ca11e2bd17f8b7b2f8a06aba16a0632")
            add_versions("1.23.4", "87d2bb0ad4fe24d2a0685a55df321e0efe4296419a9b3de03369dbe60b8acd3a")
            add_versions("1.23.5", "047bfce4fbd0da6426bd30cd19716b35a466b1c15a45525ce65b9824acb33285")
            add_versions("1.23.6", "5cae2450a1708aeb0333237a155640d5562abaf195defebc4306054565536221")
            add_versions("1.23.7", "a08a77374a4a8ab25568cddd9dad5ba7bb6d21e04c650dc2af3def6c9115ebba")
            add_versions("1.23.8", "d4f53dcaecd67d9d2926eab7c3d674030111c2491e68025848f6839e04a4d3d1")
            add_versions("1.24.0", "fd9cfb5dd6c75a347cfc641a253f0db1cebaca16b0dd37965351c6184ba595e4")
            add_versions("1.24.1", "295581b5619acc92f5106e5bcb05c51869337eb19742fdfa6c8346c18e78ff88")
            add_versions("1.24.2", "b70f8b3c5b4ccb0ad4ffa5ee91cd38075df20fdbd953a1daedd47f50fbcff47a")
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
