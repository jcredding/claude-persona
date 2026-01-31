require "../spec_helper"

describe ClaudePersona::TomlWriter do
  describe ".to_toml" do
    it "serializes minimal config with version first" do
      toml_in = <<-TOML
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config)

      # Version should be first line (uses current VERSION when nil)
      result.should start_with("version = \"#{ClaudePersona::VERSION}\"")
      result.should contain("model = \"sonnet\"")
    end

    it "preserves existing version" do
      toml_in = <<-TOML
      version = "0.1.0"
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config)

      result.should contain("version = \"0.1.0\"")
    end

    it "allows version override" do
      toml_in = <<-TOML
      version = "0.1.0"
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config, "0.2.0")

      result.should contain("version = \"0.2.0\"")
      result.should_not contain("version = \"0.1.0\"")
    end

    it "serializes full config with all sections in order" do
      toml_in = <<-TOML
      version = "0.1.1"
      description = "Test persona"
      model = "opus"

      [directories]
      allowed = ["~/projects"]

      [mcp]
      configs = ["context7"]

      [tools]
      allowed = ["Read", "Write"]
      disallowed = ["Bash(rm:*)"]

      [permissions]
      mode = "acceptEdits"

      [prompt]
      system = "You are helpful."
      initial_message = "Hello"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config)

      # Verify field order by checking positions
      version_pos = result.index("version =").not_nil!
      desc_pos = result.index("description =").not_nil!
      model_pos = result.index("model =").not_nil!
      dirs_pos = result.index("[directories]").not_nil!
      mcp_pos = result.index("[mcp]").not_nil!
      tools_pos = result.index("[tools]").not_nil!
      perms_pos = result.index("[permissions]").not_nil!
      prompt_pos = result.index("[prompt]").not_nil!

      version_pos.should be < desc_pos
      desc_pos.should be < model_pos
      model_pos.should be < dirs_pos
      dirs_pos.should be < mcp_pos
      mcp_pos.should be < tools_pos
      tools_pos.should be < perms_pos
      perms_pos.should be < prompt_pos
    end

    it "handles multiline system prompts" do
      toml_in = <<-TOML
      model = "sonnet"

      [prompt]
      system = """
      Line one.
      Line two.
      """
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config)

      result.should contain("system = \"\"\"")
      result.should contain("Line one.")
      result.should contain("Line two.")
    end

    it "round-trips a config without data loss" do
      toml_in = <<-TOML
      version = "0.1.1"
      description = "Test"
      model = "opus"

      [directories]
      allowed = ["~/projects", "~/docs"]

      [tools]
      allowed = ["Read"]

      [prompt]
      system = "Be helpful."
      TOML

      config1 = ClaudePersona::PersonaConfig.from_toml(toml_in)
      toml_out = ClaudePersona::TomlWriter.to_toml(config1)
      config2 = ClaudePersona::PersonaConfig.from_toml(toml_out)

      config2.version.should eq(config1.version)
      config2.description.should eq(config1.description)
      config2.model.should eq(config1.model)
      config2.directories.not_nil!.allowed.should eq(config1.directories.not_nil!.allowed)
      config2.tools.not_nil!.allowed.should eq(config1.tools.not_nil!.allowed)
      config2.prompt.not_nil!.system.should eq(config1.prompt.not_nil!.system)
    end

    it "escapes quotes in strings" do
      toml_in = <<-TOML
      description = "Test with \\"quotes\\""
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config)

      result.should contain("description = \"Test with \\\"quotes\\\"\"")
    end

    it "handles multiline initial_message" do
      toml_in = <<-TOML
      model = "sonnet"

      [prompt]
      initial_message = """
      Line one.
      Line two.
      """
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml_in)
      result = ClaudePersona::TomlWriter.to_toml(config)

      result.should contain("initial_message = \"\"\"")
      result.should contain("Line one.")
      result.should contain("Line two.")

      # Verify it round-trips correctly
      config2 = ClaudePersona::PersonaConfig.from_toml(result)
      config2.prompt.not_nil!.initial_message.should contain("Line one.")
      config2.prompt.not_nil!.initial_message.should contain("Line two.")
    end
  end
end
