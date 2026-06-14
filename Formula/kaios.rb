class Kaios < Formula
  desc "AI Agent Operating System in Kotlin"
  homepage "https://morning-verlu.github.io/KAI/"
  url "https://github.com/morning-verlu/KAI/releases/download/v0.1.50/kaios-0.1.50.tar"
  sha256 "f60204a085c688bd820387ff865fdf6369247fd39c93abee6a41de67d213ae58"
  license "Apache-2.0"

  depends_on "openjdk@17"

  def install
    libexec.install Dir["*"]

    (bin/"kaios").write_env_script libexec/"bin/kaios",
      JAVA_HOME: Formula["openjdk@17"].opt_prefix,
      PATH:      "#{Formula["openjdk@17"].opt_bin}:$PATH"
  end

  test do
    assert_match "kaios 0.1.50", shell_output("#{bin}/kaios --version")

    doctor = shell_output("#{bin}/kaios doctor")
    assert_match "summary: ready", doctor
    assert_match "http syscall: disabled", doctor
    assert_match "next:", doctor
    assert_match "kaios demo", doctor
    assert_match "kaios setup --ci", doctor
    assert_match "kaios analyze . --out artifacts/analysis.md --force", doctor
    refute_match "kaios run --index .", doctor
    doctor_json = shell_output("#{bin}/kaios doctor --json")
    assert_match '"schema": "kaios.doctor/v1"', doctor_json
    assert_match '"status": "ready"', doctor_json
    assert_match '"name": "model provider"', doctor_json

    help = shell_output("#{bin}/kaios help")
    assert_match "Quick start (3 steps):", help
    assert_match "kaios demo", help
    assert_match "kaios setup --ci", help
    assert_match "kaios verify", help

    empty_help = shell_output("#{bin}/kaios")
    assert_match "Quick start (3 steps):", empty_help

    empty_runs = shell_output("#{bin}/kaios runs")
    assert_match "No run snapshots found.", empty_runs
    assert_match "kaios demo", empty_runs
    assert_match "kaios setup --ci", empty_runs
    assert_match "kaios verify", empty_runs
    refute_match "kaios run \"task\"", empty_runs
    empty_runs_json = shell_output("#{bin}/kaios runs --json")
    assert_match '"schema": "kaios.runs/v1"', empty_runs_json
    assert_match '"count": 0', empty_runs_json

    unexpected_runs = shell_output("#{bin}/kaios runs extra 2>&1", 1)
    assert_match "Unexpected runs argument 'extra'.", unexpected_runs
    assert_match "Usage: kaios runs", unexpected_runs

    demo = shell_output("#{bin}/kaios demo")
    assert_match "KAI OS demo", demo
    assert_match "provider: mock", demo
    assert_match "processes:", demo
    assert_match "planner", demo
    assert_match "kaios ps latest", demo
    assert_match "kaios trace latest --json", demo
    demo_trace = demo[/trace: (\S+)/, 1]
    assert_match '"schema": "kaios.process-trace/v1"', Pathname.new(demo_trace).read

    assert_match "RUN", shell_output("#{bin}/kaios ps latest")
    runs_after_demo = shell_output("#{bin}/kaios runs")
    assert_match "ALIAS", runs_after_demo
    assert_match "latest", runs_after_demo
    runs_after_demo_json = shell_output("#{bin}/kaios runs --json")
    assert_match '"schema": "kaios.runs/v1"', runs_after_demo_json
    assert_match '"latestRunId": "run-', runs_after_demo_json
    assert_match '"alias": "latest"', runs_after_demo_json
    unexpected_ps = shell_output("#{bin}/kaios ps latest extra 2>&1", 1)
    assert_match "Unexpected ps argument 'extra'.", unexpected_ps
    assert_match "Usage: kaios ps <run-id|latest>", unexpected_ps
    latest_trace_json = shell_output("#{bin}/kaios trace latest --json")
    assert_match '"schema": "kaios.process-trace/v1"', latest_trace_json
    assert_match '"processCount": 3', latest_trace_json
    latest_trace_check = shell_output("#{bin}/kaios trace latest --check")
    assert_match "status: valid", latest_trace_check
    assert_match "processes: 3", latest_trace_check
    bug_report_help = shell_output("#{bin}/kaios help bug-report")
    assert_match "Usage: kaios bug-report", bug_report_help
    assert_match "kaios.bug-report/v1", bug_report_help
    bug_report = shell_output("#{bin}/kaios bug-report")
    assert_match "# KAI OS Bug Report", bug_report
    assert_match "kaios.bug-report/v1", bug_report
    assert_match "## Trace Contract", bug_report
    assert_match "run_id:", bug_report
    assert_match "kaios setup --ci", bug_report
    refute_match "kaios init --template research --ci", bug_report
    refute_match "secret-key", bug_report
    bug_report_json = shell_output("#{bin}/kaios bug-report --json")
    assert_match '"schema": "kaios.bug-report/v1"', bug_report_json
    assert_match '"latestRun"', bug_report_json
    assert_match '"trace"', bug_report_json
    assert_match '"kaios setup --ci"', bug_report_json
    refute_match "kaios run --index .", bug_report_json
    bug_report_out = shell_output("#{bin}/kaios bug-report --out artifacts/kaios-bug-report.md --force")
    assert_match "bug_report:", bug_report_out
    assert_match "format: markdown", bug_report_out
    assert_match "# KAI OS Bug Report", (testpath/"artifacts/kaios-bug-report.md").read

    run_help = shell_output("#{bin}/kaios run --help")
    assert_match "Usage: kaios run", run_help
    assert_match "Examples:", run_help
    assert_match "No API key is required by default", run_help
    assert_match "--trace-out", run_help
    assert_match "kaios trace latest", run_help
    refute_match "run_id:", run_help

    named_run_help = shell_output("#{bin}/kaios help run")
    assert_match "Usage: kaios run", named_run_help
    assert_match "kaios run --index . --out artifacts/project.md --force", named_run_help
    refute_match "run_id:", named_run_help

    runs_help = shell_output("#{bin}/kaios help runs")
    assert_match "kaios runs --json", runs_help
    assert_match "kaios.runs/v1", runs_help

    doctor_help = shell_output("#{bin}/kaios help doctor")
    assert_match "kaios doctor --json", doctor_help
    assert_match "kaios.doctor/v1", doctor_help

    config_show_help = shell_output("#{bin}/kaios config show --help")
    assert_match "Usage: kaios config show", config_show_help
    assert_match "Examples:", config_show_help

    named_config_show_help = shell_output("#{bin}/kaios help config show")
    assert_match "Usage: kaios config show", named_config_show_help
    config_validate_help = shell_output("#{bin}/kaios help config validate")
    assert_match "kaios config validate --json", config_validate_help
    assert_match "kaios.config-validation/v1", config_validate_help
    setup_help = shell_output("#{bin}/kaios help setup")
    assert_match "Usage: kaios setup", setup_help
    assert_match "kaios.setup/v1", setup_help
    assert_match "Existing config and CI files are kept", setup_help
    verify_help = shell_output("#{bin}/kaios help verify")
    assert_match "Usage: kaios verify", verify_help
    assert_match "one-command readiness gate", verify_help
    assert_match "kaios.verify/v1", verify_help
    init_help = shell_output("#{bin}/kaios help init")
    assert_match "--ci", init_help
    assert_match ".github/workflows/kaios.yml", init_help

    missing_config = shell_output("#{bin}/kaios config show 2>&1", 1)
    assert_match "Config file", missing_config
    assert_match "kaios init --template default", missing_config
    assert_match "kaios config templates", missing_config

    http_doctor = shell_output("KAIOS_HTTP_ALLOWLIST=example.com #{bin}/kaios doctor")
    assert_match "http syscall: 1 allowlist rule(s): example.com", http_doctor

    output = shell_output("#{bin}/kaios run \"analyze crypto market\"")
    assert_match "success: true", output
    assert_match "kaios ps latest", output
    assert_match "kaios inspect latest", output
    assert_match "kaios trace latest", output
    assert_match "kaios report latest", output
    assert_match "kaios export latest", output

    missing_run = shell_output("#{bin}/kaios inspect run-missing 2>&1", 1)
    assert_match "Run 'kaios runs' to list saved run ids.", missing_run
    assert_match "Saved runs:", missing_run

    bad_option = shell_output("#{bin}/kaios run --bad-option hello 2>&1", 1)
    assert_match "Unknown run option '--bad-option'", bad_option
    assert_match "Run 'kaios help run' for examples.", bad_option

    typo = shell_output("#{bin}/kaios analyse . 2>&1", 1)
    assert_match "Unknown command 'analyse'", typo
    assert_match "Did you mean 'kaios analyze'?", typo

    run_id = output[/run_id: (run-[a-f0-9]+)/, 1]
    assert_match "RUN #{run_id}", shell_output("#{bin}/kaios ps #{run_id}")
    assert_match "RUN #{run_id}", shell_output("#{bin}/kaios ps latest")
    trace = shell_output("#{bin}/kaios trace #{run_id}")
    assert_match "KAI PROCESS TRACE", trace
    assert_match "kaios.process-trace/v1", trace
    trace_json = shell_output("#{bin}/kaios trace #{run_id} --json")
    assert_match '"schema": "kaios.process-trace/v1"', trace_json
    assert_match '"processCount": 3', trace_json
    trace_check = shell_output("#{bin}/kaios trace #{run_id} --check")
    assert_match "schema: kaios.process-trace/v1", trace_check
    assert_match "status: valid", trace_check
    trace_help = shell_output("#{bin}/kaios help trace")
    assert_match "kaios trace latest --check", trace_help
    assert_match "validate the trace contract", trace_help
    latest_run_trace_json = shell_output("#{bin}/kaios trace latest --json")
    assert_match "\"runId\": \"#{run_id}\"", latest_run_trace_json
    trace_out = shell_output("#{bin}/kaios trace #{run_id} --json --out artifacts/trace.json")
    assert_match "trace:", trace_out
    assert_match "format: json", trace_out
    assert_match '"schema": "kaios.process-trace/v1"', (testpath/"artifacts/trace.json").read
    protected_trace = shell_output("#{bin}/kaios trace #{run_id} --json --out artifacts/trace.json 2>&1", 1)
    assert_match "already exists", protected_trace
    assert_match "Use --force", protected_trace

    run_trace_output = shell_output("#{bin}/kaios run --trace-out artifacts/run-trace.json \"record trace artifact\"")
    assert_match "trace:", run_trace_output
    assert_match '"schema": "kaios.process-trace/v1"', (testpath/"artifacts/run-trace.json").read

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
    retry_validate_json = shell_output("#{bin}/kaios config validate --config retry.json --json")
    assert_match '"schema": "kaios.config-validation/v1"', retry_validate_json
    assert_match '"valid": true', retry_validate_json
    assert_match '"workflowName": "retry"', retry_validate_json

    init_ci = shell_output("#{bin}/kaios init --template research --ci")
    assert_match "created_ci:", init_ci
    assert_match "git add kaios.json .github/workflows/kaios.yml", init_ci
    workflow = (testpath/".github/workflows/kaios.yml").read
    assert_match 'KAIOS_VERSION: "0.1.50"', workflow
    assert_match "KAIOS_MODEL_PROVIDER: mock", workflow
    assert_match "kaios verify --config 'kaios.json'", workflow
    refute_match "kaios doctor --json", workflow
    refute_match "kaios config validate --config 'kaios.json' --json", workflow
    refute_match "kaios trace latest --check", workflow
    init_ci_validate_json = shell_output("#{bin}/kaios config validate --json")
    assert_match '"workflowName": "research"', init_ci_validate_json
    assert_match '"valid": true', init_ci_validate_json
    configured_doctor = shell_output("#{bin}/kaios doctor")
    assert_match "kaios verify --config kaios.json", configured_doctor
    refute_match "kaios setup --ci", configured_doctor
    configured_bug_report_json = shell_output("#{bin}/kaios bug-report --json")
    assert_match '"kaios verify --config kaios.json"', configured_bug_report_json
    refute_match '"kaios setup --ci"', configured_bug_report_json

    (testpath/"setup-fixture").mkpath
    setup_output = shell_output("cd setup-fixture && #{bin}/kaios setup --ci")
    assert_match "schema: kaios.setup/v1", setup_output
    assert_match "requested_template: research", setup_output
    assert_match "config_action: created", setup_output
    assert_match "validation: valid", setup_output
    assert_match "ci: created", setup_output
    setup_json = shell_output("cd setup-fixture && #{bin}/kaios setup --json")
    assert_match '"schema": "kaios.setup/v1"', setup_json
    assert_match '"requestedTemplate": "research"', setup_json
    assert_match '"action": "existing"', setup_json
    setup_workflow = (testpath/"setup-fixture/.github/workflows/kaios.yml").read
    assert_match 'KAIOS_VERSION: "0.1.50"', setup_workflow
    assert_match "kaios verify --config 'kaios.json'", setup_workflow
    verify_output = shell_output("cd setup-fixture && #{bin}/kaios verify")
    assert_match "schema: kaios.verify/v1", verify_output
    assert_match "status: ready", verify_output
    assert_match "trace: valid", verify_output
    verify_json = shell_output("cd setup-fixture && #{bin}/kaios verify --json")
    assert_match '"schema": "kaios.verify/v1"', verify_json
    assert_match '"status": "ready"', verify_json

    (testpath/"custom-config-fixture").mkpath
    (testpath/"custom-config-fixture/kaios.json").write '{"name":"","agents":[]}'
    custom_setup = shell_output("cd custom-config-fixture && #{bin}/kaios setup --config workflows/research.json --ci")
    assert_match "doctor: ready", custom_setup
    assert_match "validation: valid", custom_setup
    assert_match "kaios verify --config workflows/research.json", custom_setup
    custom_workflow = (testpath/"custom-config-fixture/.github/workflows/kaios.yml").read
    assert_match "kaios verify --config 'workflows/research.json'", custom_workflow
    custom_verify = shell_output("cd custom-config-fixture && #{bin}/kaios verify --config workflows/research.json")
    assert_match "status: ready", custom_verify
    assert_match "doctor: ready", custom_verify
    assert_match "config: valid", custom_verify
    refute_match "Config field 'name' cannot be blank.", custom_verify

    (testpath/"bad-env-fixture").mkpath
    bad_env = "KAIOS_MODEL_PROVIDER=openai OPENAI_API_KEY=secret-key KAIOS_MEMORY_STORE=bad-store"
    bad_env_doctor = shell_output("cd bad-env-fixture && #{bad_env} #{bin}/kaios doctor 2>&1", 2)
    assert_match "summary: 2 failed", bad_env_doctor
    assert_match "OPENAI_MODEL is required", bad_env_doctor
    bad_env_setup = shell_output("cd bad-env-fixture && #{bad_env} #{bin}/kaios setup")
    assert_match "doctor: ready with 2 warning(s)", bad_env_setup
    assert_match "model provider: OPENAI_MODEL is required", bad_env_setup
    bad_env_verify = shell_output("cd bad-env-fixture && #{bad_env} #{bin}/kaios verify")
    assert_match "status: ready", bad_env_verify
    assert_match "doctor: ready with 2 warning(s)", bad_env_verify
    assert_match "memory store: Unsupported KAIOS_MEMORY_STORE 'bad-store'", bad_env_verify
    refute_match "secret-key", bad_env_setup
    refute_match "secret-key", bad_env_verify
  end
end
