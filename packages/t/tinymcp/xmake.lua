package("tinymcp")
    set_homepage("https://github.com/Qihoo360/TinyMCP")
    set_description("A lightweight C++ SDK for implementing the MCP Server.")
    set_license("MIT")

    add_urls("https://github.com/Qihoo360/TinyMCP.git")
    add_versions("2025.05.16", "be9e806c0d5ad0fef5a14b0af3788acde76e4d64")

    add_deps("jsoncpp")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("jsoncpp")
            target("tinymcp")
                set_kind("$(kind)")
                add_files("Source/Protocol/**.cpp")
                add_headerfiles("Source/Protocol/(**.h)")
                add_packages("jsoncpp")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Entity/Server.h>
            namespace Implementation
            {
                class CEchoServer : public MCP::CMCPServer<CEchoServer>
                {
                public:
                    int Initialize() override;
                private:
                    friend class MCP::CMCPServer<CEchoServer>;
                    CEchoServer() = default;
                    static CEchoServer s_Instance;
                };
            }
            namespace Implementation
            {
                int CEchoServer::Initialize()
                {
                    MCP::Implementation serverInfo;
                    SetServerInfo(serverInfo);
                    return 0;
                }
                CEchoServer CEchoServer::s_Instance;
            }
            void test() {
                auto& server = Implementation::CEchoServer::GetInstance();
                int iErrCode = server.Initialize();
            }
        ]]}))
    end)
