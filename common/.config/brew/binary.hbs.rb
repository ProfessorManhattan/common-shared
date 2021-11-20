class {{#if binName}}{{pascalcase binName}}{{else}}{{pascalcase slug}}{{/if}} < Formula
  desc "{{description}}"
  homepage "{{link.home}}"
  url "{{#if repository.github}}{{repository.github}}{{else}}https://github.com/{{profile.github}}/{{repository.prefix.github}}{{slug}}{{/if}}/releases/download/v{{version}}/{{#if binName}}{{binName}}{{else}}{{slug}}{{/if}}.tar.gz"
  version "{{version}}"
  license "{{license}}"

  {{brew_bottle_binary}}

  def install
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
    bin.install "build/bin/{{#if binName}}{{binName}}{{else}}{{slug}}{{/if}}-#{os}_#{arch}" => "{{#if binName}}{{binName}}{{else}}{{slug}}{{/if}}"
  done

  test do
    system bin/"{{#if binName}}{{binName}}{{else}}{{slug}}{{/if}}", "--version"
  end
end
