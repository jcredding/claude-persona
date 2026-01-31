require "../spec_helper"

describe "update integration" do
  describe "update help" do
    it "outputs help for 'update help' subcommand" do
      output = run_update_help

      output.should contain("claude-persona update")
      output.should contain("Update to latest version")
      output.should contain("update preview")
      output.should contain("update force")
      output.should contain("update help")
      output.should contain("raw.githubusercontent.com")
    end
  end

  describe "main help includes update" do
    it "shows update commands in main help" do
      output = run_main_help

      output.should contain("update")
      output.should contain("Update to latest version")
      output.should contain("update preview")
      output.should contain("update force")
    end
  end
end

def run_update_help : String
  Process.run("build/claude-persona", ["update", "help"], output: :pipe, error: :pipe) do |process|
    process.output.gets_to_end
  end
end

def run_main_help : String
  Process.run("build/claude-persona", ["help"], output: :pipe, error: :pipe) do |process|
    process.output.gets_to_end
  end
end
