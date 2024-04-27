package("uwebsockets")
    set_homepage("https://github.com/uNetworking")
    set_description("Simple, secure & standards compliant web server for the most demanding of applications.")

    set_urls("https://github.com/uNetworking/uWebSockets/archive/refs/tags/$(version).tar.gz")

    add_versions("v20.60.0", "eb72223768f93d40038181653ee5b59a53736448a6ff4e8924fd56b2fcdc00db")
    add_deps("usockets","libzip")
    on_install(function (package)
        os.cp("src/*", package:installdir("include/uwebsockets"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(){
                struct UserData {};
                uWS::SSLApp({
                    .key_file_name = "key.pem",
                    .cert_file_name = "cert.pem",
                }).get("/hello/:name", [](auto *res, auto *req) {
                    res->writeStatus("200 OK");
                       res->writeHeader("Content-Type", "text/html; charset=utf-8");
                       res->write("<h1>Hello ");
                       res->write(req->getParameter("name"));
                       res->end("!</h1>");
                }).ws<UserData>("/*", {
                    .open = [](auto *ws) {
                        ws->subscribe("oh_interesting_subject");
                    },
                    .message = [](auto *ws, std::string_view message, uWS::OpCode opCode) {
                        ws->send(message, opCode);
                    }
                }).listen(9001, [](auto *listenSocket) {
                    if (listenSocket) {
                        std::cout << "Listening on port " << 9001 << std::endl;
                    } else {
                        std::cout << "Failed to load certs or to bind to port" << std::endl;
                    }
                }).run();
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "uwebsockets/App.h"}))
    end)