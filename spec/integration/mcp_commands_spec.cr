require "../spec_helper"

describe "mcp available command" do
  it "lists user-scope MCPs with file path" do
    output = run_mcp_command("available")

    output.should contain("User scope")
    output.should contain("user-claude.json")
    output.should contain("user-mcp-http (http)")
    output.should contain("user-mcp-stdio (stdio)")
  end

  it "lists project-scope MCPs with file path" do
    output = run_mcp_command("available")

    output.should contain("Project scope")
    output.should contain("project-claude.json")
    output.should contain("project-mcp-sse (sse)")
  end

  it "shows both scopes always" do
    output = run_mcp_command("available")

    output.should contain("User scope")
    output.should contain("Project scope")
  end
end

describe "mcp list command" do
  it "lists imported MCP configs" do
    output = run_mcp_command("list")

    # test-mcp.json exists in fixtures
    output.should contain("test-mcp")
  end
end

describe "mcp show command" do
  it "displays imported MCP config JSON" do
    output = run_mcp_command("show test-mcp")

    output.should contain("mcpServers")
    output.should contain("test-mcp")
  end
end

def run_mcp_command(subcommand : String) : String
  env = {
    "CLAUDE_PERSONA_CONFIG_DIR"  => SPEC_FIXTURES.to_s,
    "CLAUDE_USER_CONFIG_PATH"    => (SPEC_CLAUDE_FIXTURES / "user-claude.json").to_s,
    "CLAUDE_PROJECT_CONFIG_PATH" => (SPEC_CLAUDE_FIXTURES / "project-claude.json").to_s,
  }

  args = ["mcp"] + subcommand.split(" ")

  Process.run("build/claude-persona", args, env: env, output: :pipe, error: :pipe) do |process|
    process.output.gets_to_end
  end
end
