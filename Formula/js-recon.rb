class JsRecon < Formula
  desc "JavaScript reconnaissance tool for mapping API endpoints and analyzing client-side security"
  homepage "https://js-recon.io"
  url "https://registry.npmjs.org/@shriyanss/js-recon/-/js-recon-1.4.1-alpha.6.tgz"
  sha256 "b19918846b6a56ef474d5e01d32ae16e4ac47733bad56187ebdefd8246f7187d"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/@shriyanss/js-recon/latest"
    regex(/"version":\s*"(\d+(?:\.\d+)+)"/i)
  end

  depends_on "node"

  def install
    # Puppeteer's bundled Chromium is not downloaded at install time.
    # The lazyload subcommand requires a browser at runtime; see caveats.
    ENV["PUPPETEER_SKIP_CHROMIUM_DOWNLOAD"] = "1"
    ENV["PUPPETEER_SKIP_DOWNLOAD"] = "1"

    system "npm", "install", *std_npm_args(ignore_scripts: false)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      The `lazyload` subcommand (and `run` pipelines that use it) require a
      Chromium-based browser at runtime. Puppeteer's bundled Chromium is not
      installed by this formula.

      Option A — install Puppeteer's managed Chromium after install:
        "$(brew --prefix)/lib/node_modules/@shriyanss/js-recon/node_modules/.bin/puppeteer" \\
          browsers install chrome

      Option B — point js-recon at an existing Chrome installation:
        export PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

      Subcommands that do not require a browser (strings, map, analyze, report,
      endpoints, mcp, cs-mast, refactor, sourcemaps) work without any browser.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/js-recon -V")
    assert_match "Usage:", shell_output("#{bin}/js-recon --help")
  end
end
