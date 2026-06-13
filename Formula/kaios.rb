class Kaios < Formula
  desc "AI Agent Operating System in Kotlin"
  homepage "https://morning-verlu.github.io/KAI/"
  url "https://github.com/morning-verlu/KAI/releases/download/v0.1.7/kaios-0.1.7.tar"
  sha256 "109717b089de36b46d8bf7faaf2a8a2766679846ddcb346d3df99810b04ec9c4"
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
  end
end
