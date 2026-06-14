class Kaios < Formula
  desc "AI Agent Operating System in Kotlin"
  homepage "https://morning-verlu.github.io/KAI/"
  url "https://github.com/morning-verlu/KAI/releases/download/v0.1.10/kaios-0.1.10.tar"
  sha256 "450c95cc198a6403765731f962ba90bc69f747970cb4945bdca7c34181e2dd09"
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

    output = shell_output("#{bin}/kaios run \"analyze crypto market\"")
    assert_match "success: true", output

    run_id = output[/run_id: (run-[a-f0-9]+)/, 1]
    assert_match "RUN #{run_id}", shell_output("#{bin}/kaios ps #{run_id}")

    (testpath/"README.md").write "# KAI OS\nContext fixture\n"
    context_output = shell_output("#{bin}/kaios run --context README.md --out artifacts/context.md \"summarize this project\"")
    assert_match "context: 1 file(s)", context_output
    assert_match "Context:", (testpath/"artifacts/context.md").read
  end
end
