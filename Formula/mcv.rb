class Mcv < Formula
  desc "Thien's tmux + Neovim (LazyVim) setup, isolated from the host's own config"
  homepage "https://github.com/IntrepidT/homebrew-mcv"
  url "https://github.com/IntrepidT/homebrew-mcv.git",
      tag:      "v0.1.0",
      revision: "382e8e99a8af25a813bcc4d4557c0e925ff8848f"
  license "Apache-2.0"
  head "https://github.com/IntrepidT/homebrew-mcv.git", branch: "main"

  depends_on "difftastic"
  depends_on "fd"
  depends_on "fzf"
  depends_on "lazygit"
  depends_on "neovim"
  depends_on "ripgrep"
  depends_on "tmux"
  depends_on "tree-sitter-cli"

  resource "tmux-resurrect" do
    url "https://github.com/tmux-plugins/tmux-resurrect/archive/cff343cf9e81983d3da0c8562b01616f12e8d548.tar.gz"
    sha256 "9f1dda18554291ee7f8a0f499e2af90bbadc2ebceb7a995bb13b76529fe0c5c9"
  end

  def install
    pkgshare.install "config/nvim", "config/tmux"
    cp pkgshare/"nvim/lazy-lock.json", pkgshare/"lazy-lock.pinned.json"
    resource("tmux-resurrect").stage(pkgshare/"tmux/plugins/tmux-resurrect")
    bin.install "bin/mcv"
    inreplace bin/"mcv", "@MCV_SHARE@", opt_pkgshare
  end

  def caveats
    <<~EOS
      Run `mcv` to start. The host's ~/.config/nvim and tmux sessions are never touched.
      Plugins download on first launch, pinned to lazy-lock.json.

      Icons need a Nerd Font in the terminal:
        brew install --cask font-jetbrains-mono-nerd-font

      To remove everything:
        mcv clean && brew uninstall mcv
    EOS
  end

  test do
    assert_match "usage: mcv", shell_output("#{bin}/mcv help")
    assert_path_exists pkgshare/"nvim/init.lua"
    assert_path_exists pkgshare/"lazy-lock.pinned.json"
    assert_path_exists pkgshare/"tmux/plugins/tmux-resurrect/resurrect.tmux"
  end
end
