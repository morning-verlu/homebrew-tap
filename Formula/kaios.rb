class Kaios < Formula
  desc "AI Agent Operating System in Kotlin"
  homepage "https://morning-verlu.github.io/KAI/"
  url "https://github.com/morning-verlu/KAI/releases/download/v0.1.20/kaios-0.1.20.tar"
  sha256 "8fa75c304107798abbc9cfd5e35c005f7a4747ba4a3be2f3025efad4b4dad72f"
  license "Apache-2.0"

  depends_on "openjdk@17"

  def install
    libexec.install Dir["*"]

    (bin/"kaios").write_env_script libexec/"bin/kaios",
      JAVA_HOME: Formula["openjdk@17"].opt_prefix,
      PATH:      "#{Formula["openjdk@17"].opt_bin}:$PATH"
  end

  test do
    assert_match "kaios 0.1.20", shell_output("#{bin}/kaios --version")

    doctor = shell_output("#{bin}/kaios doctor")
    assert_match "summary: ready", doctor
    assert_match "http syscall: disabled", doctor
    assert_match "next:", doctor
    assert_match "kaios analyze . --out artifacts/analysis.md --force", doctor

    help = shell_output("#{bin}/kaios help")
    assert_match "Quick start (3 steps):", help
    assert_match "kaios run --index . --out artifacts/project.md --force", help

    http_doctor = shell_output("KAIOS_HTTP_ALLOWLIST=example.com #{bin}/kaios doctor")
    assert_match "http syscall: 1 allowlist rule(s): example.com", http_doctor

    output = shell_output("#{bin}/kaios run \"analyze crypto market\"")
    assert_match "success: true", output

    bad_option = shell_output("#{bin}/kaios run --bad-option hello 2>&1", 1)
    assert_match "Unknown run option '--bad-option'", bad_option

    run_id = output[/run_id: (run-[a-f0-9]+)/, 1]
    assert_match "RUN #{run_id}", shell_output("#{bin}/kaios ps #{run_id}")

    (testpath/"README.md").write "# KAI OS\nContext fixture\n"
    (testpath/".kaiosignore").write "secrets/\n"
    (testpath/"secrets").mkpath
    (testpath/"secrets/private.md").write "ignore me\n"

    preview = shell_output("#{bin}/kaios context .")
    assert_match "README.md", preview
    refute_match "secrets/private.md", preview

    analysis_output = shell_output("#{bin}/kaios analyze . --out artifacts/analysis.md")
    assert_match "analysis:", analysis_output
    analysis = (testpath/"artifacts/analysis.md").read
    assert_match "KAI OS Workspace Analysis", analysis
    assert_match "Language Map", analysis
    assert_match "Suggested KAI OS Commands", analysis

    json_output = shell_output("#{bin}/kaios analyze . --format json --out artifacts/analysis.json")
    assert_match "format: json", json_output
    json_analysis = (testpath/"artifacts/analysis.json").read
    assert_match '"schemaVersion": 1', json_analysis
    assert_match '"summary"', json_analysis

    index = shell_output("#{bin}/kaios index .")
    assert_match "WORKSPACE INDEX", index
    assert_match "README.md", index
    refute_match "secrets/private.md", index

    context_output = shell_output("#{bin}/kaios run --index . --context . --out artifacts/context.md \"summarize this project\"")
    assert_match "index:", context_output
    assert_match "context: 1 file(s)", context_output
    artifact = (testpath/"artifacts/context.md").read
    assert_match "Workspace Index:", artifact
    assert_match "Context:", artifact

    forced_context_output = shell_output("#{bin}/kaios run --index . --context . --out artifacts/context.md --force \"summarize this project\"")
    assert_match "success: true", forced_context_output

    (testpath/"retry.json").write <<~JSON
      {
        "name": "retry",
        "agents": [
          {
            "id": "worker",
            "tools": ["echo"],
            "retries": 2
          }
        ]
      }
    JSON

    retry_show = shell_output("#{bin}/kaios config show --config retry.json")
    assert_match "retries=2", retry_show
  end
end
