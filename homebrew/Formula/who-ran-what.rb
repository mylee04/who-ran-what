class WhoRanWhat < Formula
  desc "Track your AI agent and skill usage - analytics for Claude Code"
  homepage "https://github.com/mylee04/who-ran-what"
  url "https://github.com/mylee04/who-ran-what/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256_WILL_BE_UPDATED_ON_RELEASE"
  license "MIT"
  head "https://github.com/mylee04/who-ran-what.git", branch: "main"

  depends_on "jq" => :recommended

  def install
    # Install the main script
    bin.install "bin/who-ran-what"

    # Install library files maintaining directory structure
    (lib/"who-ran-what").install Dir["lib/who-ran-what/*"]

    # Create wrapper script that sets up correct paths
    (bin/"wr").write <<~EOS
      #!/bin/bash
      exec "#{bin}/who-ran-what" "$@"
    EOS

    (bin/"wrp").write <<~EOS
      #!/bin/bash
      exec "#{bin}/who-ran-what" project "$@"
    EOS
  end

  def caveats
    <<~EOS
      To get started, run:
        wr help

      Make sure you have Claude Code session data in ~/.claude/projects/
    EOS
  end

  test do
    assert_match "who-ran-what version", shell_output("#{bin}/who-ran-what version")
    assert_match "USAGE", shell_output("#{bin}/who-ran-what help")
  end
end
