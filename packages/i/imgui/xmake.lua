package("imgui")
    set_homepage("https://github.com/ocornut/imgui")
    set_description("Bloat-free Immediate Mode Graphical User interface for C++ with minimal dependencies")
    set_license("MIT")

    add_urls("https://github.com/ocornut/imgui/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/ocornut/imgui.git", {alias = "git"})

    -- don't forget to add the docking versions as well
    add_versions("v1.92.5", "0eb50fe9aeba1a51f96b5843c7f630a32ed2e9362d693c61b87e4fa870cf826d")
    add_versions("v1.92.4", "0e175d4d941112532549b418ced0bd546abe9024ecb9b5f431f8a67a2197b0ba")
    add_versions("v1.92.3", "9212ee7c4718b1466a5d99e64bce3ef1965704afea4ba651f8d978d0791b7c7c")
    add_versions("v1.92.2", "994aad785a0aa572538d909b923bf0a64e7bfe5ab3360d8ae0e397c6bb312c04")
    add_versions("v1.92.1", "32c237c2abf67a2ffccaac17192f711d4a787554b4133187a153d49057d6109c")
    add_versions("v1.92.0", "42250c45df2736bcef867ae4ff404d138e5135cd36466c63143b1ea3b1c81091")
    add_versions("v1.91.9", "3872a5f90df78fced023c1945f4466b654fd74573370b77b17742149763a7a7c")
    add_versions("v1.91.8", "db3a2e02bfd6c269adf0968950573053d002f40bdfb9ef2e4a90bce804b0f286")
    add_versions("v1.91.7", "2001dab4bdd7d178d8277d3b17c40aa1ff1e76e2ccac5e7ab8c6daf9756312c2")
    add_versions("v1.91.6", "c5fbc5dcab1d46064001c3b84d7a88812985cde7e0e9ced03f5677bec1ba502a")
    add_versions("v1.91.5", "2aa2d169c569368439e5d5667e0796d09ca5cc6432965ce082e516937d7db254")
    add_versions("v1.91.4", "a455c28d987c78ddf56aab98ce0ff0fda791a23a2ec88ade46dd106b837f0923")
    add_versions("v1.91.3", "29949d7b300c30565fbcd66398100235b63aa373acfee0b76853a7aeacd1be28")
    add_versions("v1.91.2", "a3c4fd857a0a48f6edad3e25de68fa1e96d2437f1665039714d1de9ad579b8d0")
    add_versions("v1.91.1", "2c13a8909f75222c836abc9b3f60cef31c445f3f41f95d8242118ea789d145ca")
    add_versions("v1.91.0", "6e62c87252e6b3725ba478a1c04dc604aa0aaeec78fedcf4011f1e52548f4cc9")
    add_versions("v1.90.9", "04943919721e874ac75a2f45e6eb6c0224395034667bf508923388afda5a50bf")
    add_versions("v1.90.8", "f606b4fb406aa0f8dad36d4a9dd3d6f0fd39f5f0693e7468abc02d545fb505ae")
    add_versions("v1.90.7", "872574217643d4ad7e9e6df420bb8d9e0d468fb90641c2bf50fd61745e05de99")
    add_versions("v1.90.6", "70b4b05ac0938e82b4d5b8d59480d3e2ca63ca570dfb88c55023831f387237ad")
    add_versions("v1.90.5", "e94b48dba7311c85ba8e3e6fe7c734d76a0eed21b2b42c5180fd5706d1562241")
    add_versions("v1.90.4", "5d9dc738af74efa357f2a9fc39fe4a28d29ef1dfc725dd2977ccf3f3194e996e")
    add_versions("v1.90.3", "40b302d01092c9393373b372fe07ea33ac69e9491893ebab3bf952b2c1f5fd23")
    add_versions("v1.90.2", "452d1c11e5c4b4dfcca272915644a65f1c076498e8318b141ca75cd30470dd68")
    add_versions("v1.90.1", "21dcc985bb2ae8fe48047c86135dbc438d6980a8f2e08babbda5be820592f282")
    add_versions("v1.90",   "170986e6a4b83d165bfc1d33c2c5a5bc2d67e5b97176287485c51a2299249296")
    add_versions("v1.89.9", "1acc27a778b71d859878121a3f7b287cd81c29d720893d2b2bf74455bf9d52d6")
    add_versions("v1.89.8", "6680ccc32430009a8204291b1268b2367d964bd6d1b08a4e0358a017eb8e8c9e")
    add_versions("v1.89.7", "115ee9e242af98a884302ac0f6ca3b2b26b1f10c660205f5e7ad9f1d1c96d269")
    add_versions("v1.89.6", "e95d1cba1481e66386acda3e7da19cd738da86c6c2a140a48fa55046e5f6e208")
    add_versions("v1.89.5", "eab371005c86dd029523a0c4ba757840787163740d45c1f4e5a110eb21820546")
    add_versions("v1.89.4", "69f1e83adcab3fdd27b522f5075f407361b0d3875e3522b13d33bc2ae2c7d48c")
    add_versions("v1.89.3", "3b665fadd5580b7ef494d5d8bb1c12b2ec53ee723034caf43332956381f5d631")
    add_versions("v1.89",   "4038b05bd44c889cf40be999656d3871a0559916708cb52a6ae2fa6fa35c5c60")
    add_versions("v1.88",   "9f14c788aee15b777051e48f868c5d4d959bd679fc5050e3d2a29de80d8fd32e")
    add_versions("v1.87",   "b54ceb35bda38766e36b87c25edf7a1cd8fd2cb8c485b245aedca6fb85645a20")
    add_versions("v1.86",   "6ba6ae8425a19bc52c5e067702c48b70e4403cd339cba02073a462730a63e825")
    add_versions("v1.85",   "7ed49d1f4573004fa725a70642aaddd3e06bb57fcfe1c1a49ac6574a3e895a77")
    add_versions("v1.84.2", "35cb5ca0fb42cb77604d4f908553f6ef3346ceec4fcd0189675bdfb764f62b9b")
    add_versions("v1.84.1", "292ab54cfc328c80d63a3315a242a4785d7c1cf7689fbb3d70da39b34db071ea")
    add_versions("v1.83",   "ccf3e54b8d1fa30dd35682fc4f50f5d2fe340b8e29e08de71287d0452d8cc3ff")
    add_versions("v1.82",   "fefa2804bd55f3d25b134af08c0e1f86d4d059ac94cef3ee7bd21e2f194e5ce5")
    add_versions("v1.81",   "f7c619e03a06c0f25e8f47262dbc32d61fd033d2c91796812bf0f8c94fca78fb")
    add_versions("v1.80",   "d7e4e1c7233409018437a646680316040e6977b9a635c02da93d172baad94ce9")
    add_versions("v1.79",   "f1908501f6dc6db8a4d572c29259847f6f882684b10488d3a8d2da31744cd0a4")
    add_versions("v1.78",   "f70bbb17581ee2bd42fda526d9c3dc1a5165f3847ff047483d4d7980e166f9a3")
    add_versions("v1.77",   "c0dae830025d4a1a169df97409709f40d9dfa19f8fc96b550052224cbb238fa8")
    add_versions("v1.76",   "e482dda81330d38c87bd81597cacaa89f05e20ed2c4c4a93a64322e97565f6dc")
    add_versions("v1.75",   "1023227fae4cf9c8032f56afcaea8902e9bfaad6d9094d6e48fb8f3903c7b866")

    add_versions("git:v1.92.5-docking", "v1.92.5-docking")
    add_versions("git:v1.92.4-docking", "v1.92.4-docking")
    add_versions("git:v1.92.3-docking", "v1.92.3-docking")
    add_versions("git:v1.92.2-docking", "v1.92.2-docking")
    add_versions("git:v1.92.1-docking", "v1.92.1-docking")
    add_versions("git:v1.92.0-docking", "v1.92.0-docking")
    add_versions("git:v1.91.9-docking", "v1.91.9-docking")
    add_versions("git:v1.91.8-docking", "v1.91.8-docking")
    add_versions("git:v1.91.7-docking", "v1.91.7-docking")
    add_versions("git:v1.91.6-docking", "v1.91.6-docking")
    add_versions("git:v1.91.5-docking", "v1.91.5-docking")
    add_versions("git:v1.91.4-docking", "v1.91.4-docking")
    add_versions("git:v1.91.3-docking", "v1.91.3-docking")
    add_versions("git:v1.91.2-docking", "v1.91.2-docking")
    add_versions("git:v1.91.1-docking", "v1.91.1-docking")
    add_versions("git:v1.91.0-docking", "v1.91.0-docking")
    add_versions("git:v1.90.9-docking", "v1.90.9-docking")
    add_versions("git:v1.90.8-docking", "v1.90.8-docking")
    add_versions("git:v1.90.7-docking", "v1.90.7-docking")
    add_versions("git:v1.90.6-docking", "v1.90.6-docking")
    add_versions("git:v1.90.5-docking", "v1.90.5-docking")
    add_versions("git:v1.90.4-docking", "v1.90.4-docking")
    add_versions("git:v1.90.3-docking", "v1.90.3-docking")
    add_versions("git:v1.90.2-docking", "v1.90.2-docking")
    add_versions("git:v1.90.1-docking", "v1.90.1-docking")
    add_versions("git:v1.90-docking",   "v1.90-docking")
    add_versions("git:v1.89.9-docking", "v1.89.9-docking")
    add_versions("git:v1.89.8-docking", "v1.89.8-docking")
    add_versions("git:v1.89.7-docking", "v1.89.7-docking")
    add_versions("git:v1.89.6-docking", "823a1385a269d923d35b82b2f470f3ae1fa8b5a3")
    add_versions("git:v1.89.5-docking", "0ea3b87bd63ecbf359585b7c235839146e84dedb")
    add_versions("git:v1.89.4-docking", "9e30fb0ec1b44dc1b041db6bdd53b130b2a18509")
    add_versions("git:v1.89.3-docking", "192196711a7d0d7c2d60454d42654cf090498a74")
    add_versions("git:v1.89-docking",   "94e850fd6ff9eceb98fda3147e3ffd4781ad2dc7")
    add_versions("git:v1.88-docking",   "9cd9c2eff99877a3f10a7f9c2a3a5b9c15ea36c6")
    add_versions("git:v1.87-docking",   "1ee252772ae9c0a971d06257bb5c89f628fa696a")
    add_versions("git:v1.85-docking",   "dc8c3618e8f8e2dada23daa1aa237626af341fd8")
    add_versions("git:v1.83-docking",   "80b5fb51edba2fd3dea76ec3e88153e2492243d1")

    -- Fix conflicting IMGUI_API definitions in v1.92.0 only (https://github.com/ocornut/imgui/pull/8729)
    add_patches("v1.92.0", "patches/v1.92.0/fix_imgui_api.patch", "e8ca0502056acf356f83703e7190dda87fde43ed245f65f0fb55b85cd164ed83")
    add_patches("v1.92.0-docking", "patches/v1.92.0/fix_imgui_api.patch", "e8ca0502056acf356f83703e7190dda87fde43ed245f65f0fb55b85cd164ed83")

    add_configs("dx9",              {description = "Enable the dx9 backend", default = false, type = "boolean"})
    add_configs("dx10",             {description = "Enable the dx10 backend", default = false, type = "boolean"})
    add_configs("dx11",             {description = "Enable the dx11 backend", default = false, type = "boolean"})
    add_configs("dx12",             {description = "Enable the dx12 backend", default = false, type = "boolean"})
    add_configs("glfw",             {description = "Enable the glfw backend", default = false, type = "boolean"})
    add_configs("opengl2",          {description = "Enable the opengl2 backend", default = false, type = "boolean"})
    add_configs("opengl3",          {description = "Enable the opengl3 backend", default = false, type = "boolean"})
    add_configs("sdl2",             {description = "Enable the sdl2 backend with sdl2_renderer", default = false, type = "boolean"})
    add_configs("sdl2_no_renderer", {description = "Enable the sdl2 backend without sdl2_renderer", default = false, type = "boolean"})
    add_configs("sdl2_renderer",    {description = "Enable the sdl2 renderer backend", default = false, type = "boolean"})
    add_configs("sdl3",             {description = "Enable the sdl3 backend with sdl3_renderer", default = false, type = "boolean"})
    add_configs("sdl3_renderer",    {description = "Enable the sdl3 renderer backend", default = false, type = "boolean"})
    add_configs("sdl3_gpu",         {description = "Enable the sdl3 gpu backend", default = false, type = "boolean"})
    add_configs("vulkan",           {description = "Enable the vulkan backend", default = false, type = "boolean"})
    add_configs("volk",             {description = "Enable the vulkan backend, and use volk to load Vulkan functions", default = false, type = "boolean"})
    add_configs("win32",            {description = "Enable the win32 backend", default = false, type = "boolean"})
    add_configs("osx",              {description = "Enable the OS X backend", default = false, type = "boolean"})
    add_configs("wgpu",             {description = "Enable the wgpu backend", default = false, type = "boolean"})
    add_configs("wgpu_backend",     {description = "Use specific wgpu backend", default = "wgpu", type = "string", values = {"wgpu", "dawn"}})
    add_configs("freetype",         {description = "Use FreeType to build and rasterize the font atlas", default = false, type = "boolean"})
    add_configs("user_config",      {description = "Use user config (disables test!)", default = nil, type = "string"})
    add_configs("wchar32",          {description = "Use 32-bit for ImWchar (default is 16-bit)", default = false, type = "boolean"})


    -- deprecated configs (kept for backwards compatibility)
    add_configs("sdlrenderer",  {description = "(deprecated)", default = false, type = "boolean"})
    add_configs("glfw_opengl3", {description = "(deprecated)", default = false, type = "boolean"})
    add_configs("glfw_vulkan",  {description = "(deprecated)", default = false, type = "boolean"})
    add_configs("sdl2_opengl3", {description = "(deprecated)", default = false, type = "boolean"})

    add_includedirs("include", "include/imgui", "include/backends", "include/misc/cpp")

    if is_plat("windows", "mingw") then
        add_syslinks("imm32")
    end

    on_load(function (package)
        -- begin: backwards compatibility
        if package:config("sdl2") or package:config("sdlrenderer") then
            package:config_set("sdl2_renderer", true)
        end
        if package:config("glfw_opengl3") then
            package:config_set("glfw", true)
            package:config_set("opengl3", true)
        end
        if package:config("glfw_vulkan") then
            package:config_set("glfw", true)
            package:config_set("vulkan", true)
        end
        if package:config("sdl2_opengl3") then
            package:config_set("sdl2", true)
            package:config_set("opengl3", true)
        end
        -- end: backwards compatibility
        if package:config("shared") and is_plat("windows", "mingw") then
            package:add("defines", "IMGUI_API=__declspec(dllimport)")
        end
        if package:config("glfw") then
            package:add("deps", "glfw")
        end
        if package:config("opengl3") then
            if not package:gitref() and package:version():lt("1.84") then
                package:add("deps", "glad")
                package:add("defines", "IMGUI_IMPL_OPENGL_LOADER_GLAD")
            end
        end
        if package:config("sdl2_no_renderer") then
            package:add("deps", "libsdl2")
        end
        if package:config("sdl2_renderer") then
            package:add("deps", "libsdl2 >=2.0.17")
        end
        if package:config("sdl3") or package:config("sdl3_renderer") or package:config("sdl3_gpu") then
            package:add("deps", "libsdl3")
        end
        if package:config("vulkan") then
            package:add("deps", "vulkan-headers")
        end
        if package:config("volk") then
            package:add("deps", "volk")
        end
        if package:config("wgpu") then
            package:add("deps", "wgpu-native")
            if package:config("wgpu_backend") then
                package:add("defines", "IMGUI_IMPL_WEBGPU_BACKEND_" .. string.upper(package:config("wgpu_backend")))
            end
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
        if package:config("osx") then
            package:add("frameworks", "Cocoa", "Carbon", "GameController")
        end
    end)

    on_install(function (package)
        local configs = {
            dx9              = package:config("dx9"),
            dx10             = package:config("dx10"),
            dx11             = package:config("dx11"),
            dx12             = package:config("dx12"),
            glfw             = package:config("glfw"),
            opengl2          = package:config("opengl2"),
            opengl3          = package:config("opengl3"),
            glad             = package:config("opengl3") and (not package:gitref() and package:version():lt("1.84")),
            sdl2             = package:config("sdl2") or package:config("sdl2_no_renderer"),
            sdl2_renderer    = package:config("sdl2_renderer"),
            sdl3             = package:config("sdl3"),
            sdl3_renderer    = package:config("sdl3_renderer"),
            sdl3_gpu         = package:config("sdl3_gpu"),
            vulkan           = package:config("vulkan"),
            volk             = package:config("volk"),
            win32            = package:config("win32"),
            osx              = package:config("osx"),
            wgpu             = package:config("wgpu"),
            freetype         = package:config("freetype"),
            user_config      = package:config("user_config"),
            wchar32          = package:config("wchar32")
        }

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("user_config") ~= nil then return end
        local includes = {"imgui.h"}
        local defines
        if package:config("sdl2_renderer") or package:config("sdl2_no_renderer") then
            table.insert(includes, "SDL.h")
            defines = "SDL_MAIN_HANDLED"
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                IMGUI_CHECKVERSION();
                ImGui::CreateContext();
                ImGuiIO& io = ImGui::GetIO();
                ImGui::NewFrame();
                ImGui::Text("Hello, world!");
                ImGui::ShowDemoWindow(NULL);
                ImGui::Render();
                ImGui::DestroyContext();
            }
        ]]}, {configs = {languages = "c++14", defines = defines}, includes = includes}))
    end)
