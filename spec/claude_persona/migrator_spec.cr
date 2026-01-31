require "../spec_helper"

describe ClaudePersona::Migrator do
  describe ".needs_upgrade?" do
    it "returns true when version is nil" do
      toml = <<-TOML
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml)
      ClaudePersona::Migrator.needs_upgrade?(config).should be_true
    end

    it "returns true when version is older than current" do
      toml = <<-TOML
      version = "0.0.1"
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml)
      ClaudePersona::Migrator.needs_upgrade?(config).should be_true
    end

    it "returns false when version matches current" do
      toml = <<-TOML
      version = "#{ClaudePersona::VERSION}"
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml)
      ClaudePersona::Migrator.needs_upgrade?(config).should be_false
    end
  end

  describe ".effective_version" do
    it "returns version when present" do
      toml = <<-TOML
      version = "1.2.3"
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml)
      ClaudePersona::Migrator.effective_version(config).should eq("1.2.3")
    end

    it "returns 0.0.0 when version is nil" do
      toml = <<-TOML
      model = "sonnet"
      TOML

      config = ClaudePersona::PersonaConfig.from_toml(toml)
      ClaudePersona::Migrator.effective_version(config).should eq("0.0.0")
    end
  end

  describe ".compare_versions" do
    it "compares equal versions" do
      ClaudePersona::Migrator.compare_versions("1.0.0", "1.0.0").should eq(0)
    end

    it "compares major versions" do
      ClaudePersona::Migrator.compare_versions("1.0.0", "2.0.0").should eq(-1)
      ClaudePersona::Migrator.compare_versions("2.0.0", "1.0.0").should eq(1)
    end

    it "compares minor versions" do
      ClaudePersona::Migrator.compare_versions("1.1.0", "1.2.0").should eq(-1)
      ClaudePersona::Migrator.compare_versions("1.2.0", "1.1.0").should eq(1)
    end

    it "compares patch versions" do
      ClaudePersona::Migrator.compare_versions("1.0.1", "1.0.2").should eq(-1)
      ClaudePersona::Migrator.compare_versions("1.0.2", "1.0.1").should eq(1)
    end

    it "handles different length versions" do
      ClaudePersona::Migrator.compare_versions("1.0", "1.0.0").should eq(0)
      ClaudePersona::Migrator.compare_versions("1.0", "1.0.1").should eq(-1)
    end
  end

  describe "Migrator::Result" do
    it "has all expected enum values" do
      ClaudePersona::Migrator::Result::AlreadyCurrent.should_not be_nil
      ClaudePersona::Migrator::Result::Upgraded.should_not be_nil
      ClaudePersona::Migrator::Result::Failed.should_not be_nil
      ClaudePersona::Migrator::Result::ReadOnly.should_not be_nil
    end
  end
end
