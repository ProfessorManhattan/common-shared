require "language/node"

class {{#if binName}}{{pascalcase binName}}{{else}}{{pascalcase slug}}{{/if}} < Formula
  desc "{{description}}"
  homepage "{{link.home}}"
  url "https://registry.npmjs.org/{{#if customPackageName}}{{customPackageName}}{{else}}@{{profile.npmjs_organization}}/{{repository.prefix.github}}{{slug}}{{/if}}/-/{{#if customPackageName}}{{customPackageName}}{{else}}{{repository.prefix.github}}{{slug}}{{/if}}-{{version}}.tgz"
  sha256 "{{sha256.npm_tgz}}"
  license "{{license}}"

  {{brew_bottle_node}}

  depends_on "node" => :build

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    output = shell_output("#{bin}/{{#if customPackageName}}{{customPackageName}}{{else}}@{{profile.npmjs_organization}}/{{repository.prefix.github}}{{slug}}{{/if}} --help 2>&1", 1)
    assert_match "You can log in via contentful login", output
    assert_match "Or provide a management token via --management-token argument", output
  end
end
