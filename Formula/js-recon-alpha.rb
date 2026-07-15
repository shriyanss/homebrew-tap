class JsReconAlpha < Formula
  desc "JavaScript recon tool for API mapping and client-side security analysis"
  homepage "https://js-recon.io"
  url "https://registry.npmjs.org/@shriyanss/js-recon/-/js-recon-1.4.1-alpha.8.tgz"
  sha256 "f48ac837e38e16916d474c9a399a0fb3476e04df62b4c6adaceda4d26a91ff82"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/@shriyanss/js-recon/alpha"
    regex(/"version":\s*"(\S+)"/i)
  end

  # Same binary name as shriyanss/tap/js-recon (the stable formula) — avoid
  # linking into a shared bin/ automatically so both can coexist unlinked.
  keg_only "js-recon-alpha installs the same `js-recon` binary name as shriyanss/tap/js-recon"

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
      This is the alpha channel of js-recon — it tracks the latest prerelease,
      not the stable release. For the stable release, install
      `shriyanss/tap/js-recon` instead.

      This formula is keg-only and does not link into Homebrew's shared bin/,
      since it installs the same `js-recon` binary name as the stable
      formula. To use it:
        "$(brew --prefix)/opt/js-recon-alpha/bin/js-recon" --help
      Or link it explicitly (this will conflict with a linked stable install):
        brew link --overwrite js-recon-alpha

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
