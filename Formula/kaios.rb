class Kaios < Formula
  desc "AI Agent Operating System in Kotlin"
  homepage "https://morning-verlu.github.io/KAI/"
  url "https://github.com/morning-verlu/KAI/releases/download/v0.1.12/kaios-0.1.12.tar"
  sha256 "887838dd568218e785be6d1364998bc9f1fe8f728924b7ec5d52a44d159757dc"
  license "Apache-2.0"

  depends_on "openjdk@17"

  def install
    libexec.install Dir["*"]

    (bin/"kaios").write_env_script libexec/"bin/kaios",
      JAVA_HOME: Formula["openjdk@17"].opt_prefix,
      PATH:      "#{Formula["openjdk@17"].opt_bin}:$PATH"
  end

  test do
    doctor = shell_output("#{bin}/kaios doctor")
    assert_match "summary: ready", doctor
    assert_match "http syscall: disabled", doctor

    http_doctor = shell_output("KAIOS_HTTP_ALLOWLIST=example.com #{bin}/kaios doctor")
    assert_match "http syscall: 1 allowlist rule(s): example.com", http_doctor

    output = shell_output("#{bin}/kaios run \"analyze crypto market\"")
    assert_match "success: true", output

    run_id = output[/run_id: (run-[a-f0-9]+)/, 1]
    assert_match "RUN #{run_id}", shell_output("#{bin}/kaios ps #{run_id}")

    (testpath/"README.md").write "# KAI OS\nContext fixture\n"
    (testpath/".kaiosignore").write "secrets/\n"
    (testpath/"secrets").mkpath
    (testpath/"secrets/private.md").write "ignore me\n"

    preview = shell_output("#{bin}/kaios context .")
    assert_match "README.md", preview
    refute_match "secrets/private.md", preview

    context_output = shell_output("#{bin}/kaios run --context . --out artifacts/context.md \"summarize this project\"")
    assert_match "context: 1 file(s)", context_output
    assert_match "Context:", (testpath/"artifacts/context.md").read
  end
end
