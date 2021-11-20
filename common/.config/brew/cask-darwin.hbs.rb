cask "electron" do
  arch = Hardware::CPU.intel? ? "x64" : "arm64"

  version "16.0.0"

  if Hardware::CPU.intel?
    sha256 "{{sha256.darwin-x64_zip}}"
  else
    sha256 "{{sha256.darwin-arm64_zip}}"
  end

  url "https://github.com/{{profile.github}}/{{repository.prefix.github}}{{slug}}/releases/download/v#{version}/{{#if binName}}{{binName}}{{else}}{{slug}}{{/if}}-#{version}-darwin-#{arch}.zip",
      verified: "github.com/{{profile.github}}/{{repository.prefix.github}}{{slug}}/"
  name "{{name}}"
  desc "{{description}}"
  homepage "{{link.home}}"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "{{name}}.app"
end
