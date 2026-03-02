#include <algorithm>
#include <csignal>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#include "khmer_engine.h"

namespace {

volatile std::sig_atomic_t g_running = 1;

std::string trim(const std::string& s) {
    size_t start = 0;
    while (start < s.size() && (s[start] == ' ' || s[start] == '\t' || s[start] == '\r' || s[start] == '\n')) {
        ++start;
    }
    size_t end = s.size();
    while (end > start && (s[end - 1] == ' ' || s[end - 1] == '\t' || s[end - 1] == '\r' || s[end - 1] == '\n')) {
        --end;
    }
    return s.substr(start, end - start);
}

std::vector<std::string> split_tab(const std::string& s) {
    std::vector<std::string> parts;
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, '\t')) {
        parts.push_back(item);
    }
    return parts;
}

void on_signal(int) {
    g_running = 0;
}

int parse_top_n(const std::string& s) {
    try {
        int v = std::stoi(s);
        return std::max(1, v);
    } catch (...) {
        return 5;
    }
}

std::string handle_line(KhmerEngineHandle engine, const std::string& line) {
    std::string input = trim(line);
    if (input.empty()) return "ERR\tempty";
    if (input == "PING") return "OK\tPONG";
    if (input == "QUIT") return "OK\tBYE";

    // Protocol:
    // PREFIX\t<top_n>\t<prefix>
    // NEXT\t<top_n>\t<w1>\t<w2>
    // SMART\t<top_n>\t<text>
    std::vector<std::string> p = split_tab(input);
    if (p.empty()) return "ERR\tbad_command";

    if (p[0] == "PREFIX" && p.size() >= 3) {
        int n = parse_top_n(p[1]);
        const char* out = khmer_engine_suggest_prefix(engine, p[2].c_str(), n);
        return std::string("OK\t") + (out ? out : "");
    }
    if (p[0] == "NEXT" && p.size() >= 4) {
        int n = parse_top_n(p[1]);
        const char* out = khmer_engine_predict_next(engine, p[2].c_str(), p[3].c_str(), n);
        return std::string("OK\t") + (out ? out : "");
    }
    if (p[0] == "SMART" && p.size() >= 3) {
        int n = parse_top_n(p[1]);
        const char* out = khmer_engine_smart(engine, p[2].c_str(), n);
        return std::string("OK\t") + (out ? out : "");
    }

    return "ERR\tunknown_command";
}

int serve(const std::string& socket_path, KhmerEngineHandle engine) {
    std::filesystem::path sock(socket_path);
    std::filesystem::create_directories(sock.parent_path());
    ::unlink(socket_path.c_str());

    int fd = ::socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) {
        std::cerr << "socket create failed\n";
        return 1;
    }

    sockaddr_un addr{};
    addr.sun_family = AF_UNIX;
    std::snprintf(addr.sun_path, sizeof(addr.sun_path), "%s", socket_path.c_str());

    if (::bind(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) {
        std::cerr << "bind failed: " << socket_path << "\n";
        ::close(fd);
        return 1;
    }

    if (::listen(fd, 16) != 0) {
        std::cerr << "listen failed\n";
        ::close(fd);
        return 1;
    }

    while (g_running) {
        int cfd = ::accept(fd, nullptr, nullptr);
        if (cfd < 0) {
            if (!g_running) break;
            continue;
        }

        std::string buffer;
        char temp[4096];
        while (g_running) {
            ssize_t n = ::read(cfd, temp, sizeof(temp));
            if (n <= 0) break;
            buffer.append(temp, static_cast<size_t>(n));
            size_t pos = 0;
            while (true) {
                size_t nl = buffer.find('\n', pos);
                if (nl == std::string::npos) {
                    buffer.erase(0, pos);
                    break;
                }
                std::string line = buffer.substr(pos, nl - pos);
                pos = nl + 1;
                std::string resp = handle_line(engine, line);
                resp.push_back('\n');
                ssize_t written = ::write(cfd, resp.data(), resp.size());
                (void)written;
                if (line == "QUIT") break;
            }
        }

        ::close(cfd);
    }

    ::close(fd);
    ::unlink(socket_path.c_str());
    return 0;
}

}  // namespace

int main(int argc, char** argv) {
    std::signal(SIGINT, on_signal);
    std::signal(SIGTERM, on_signal);

    std::string model_dir = "/opt/NextGenz/model";
    std::string socket_path = "/run/nextgenz/daemon.sock";

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--model-dir" && i + 1 < argc) {
            model_dir = argv[++i];
        } else if (arg == "--socket" && i + 1 < argc) {
            socket_path = argv[++i];
        }
    }

    KhmerEngineHandle engine = khmer_engine_create(model_dir.c_str());
    if (!engine) return 1;
    int code = serve(socket_path, engine);
    khmer_engine_destroy(engine);
    return code;
}
