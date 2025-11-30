{ pkgs, lib, config, inputs, ... }:
let
  daemonCargoToml = builtins.fromTOML (builtins.readFile ./daemon/Cargo.toml);
  packageName = daemonCargoToml.package.name;
  packageVersion = daemonCargoToml.package.version;
in
{
  dotenv.enable = true;

  # Rust configuration
  languages.rust = {
    enable = true;
    channel = "stable";
  };

  # Node.js for web UI
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_20;
    npm = {
      enable = true;
      install.enable = true;
    };
    directory = "daemon/web";
  };

  # Development packages
  packages = with pkgs; [
    gdb
    mdbook
    jq
  ];

  # Development scripts
  scripts.dev-test.exec = ''
    echo "🧪 Running development tests..."
    cargo test --all-features
  '';

  scripts.dev-run.exec = ''
    echo "🚀 Running Rayhunter daemon..."
    cargo run --release --bin rayhunter-daemon
  '';

  scripts.dev-build.exec = ''
    echo "🔨 Building Rayhunter..."
    cargo build --release
  '';

  scripts.dev-web-build.exec = ''
    echo "🌐 Building web UI..."
    cd daemon/web
    npm run build
  '';

  scripts.dev-web-dev.exec = ''
    echo "🌐 Starting web UI dev server..."
    cd daemon/web
    npm run dev
  '';

  # Environment variables
  env = {
    PROJECT_NAME = "rayhunter";
    RUST_LOG = "rayhunter=debug,info";
    CARGO_TARGET_DIR = "./target";
  };

  # Development shell setup
  enterShell = ''
    clear
    ${pkgs.figlet}/bin/figlet "Rayhunter"
    echo
    {
      echo "• IMSI Catcher Detection Tool"
      echo -e "• \033[1mv${packageVersion}\033[0m"
      echo -e " \033[0;32m✓\033[0m Development environment ready"
    } | ${pkgs.boxes}/bin/boxes -d stone -a l -i none
    echo
    echo "Available scripts:"
    echo "  • dev-test      - Run tests"
    echo "  • dev-run       - Run the daemon"
    echo "  • dev-build     - Build the project"
    echo "  • dev-web-build - Build the web UI"
    echo "  • dev-web-dev   - Start web UI dev server"
    echo ""
    echo "Workspace members:"
    echo "  • lib            - Core rayhunter library"
    echo "  • daemon         - Main daemon process"
    echo "  • check          - CLI checking tool"
    echo "  • rootshell      - Root shell utility"
    echo "  • telcom-parser  - Telecommunications parser"
    echo "  • installer      - Installation tool"
    echo ""
  '';

  # See full reference at https://devenv.sh/reference/options/
}
