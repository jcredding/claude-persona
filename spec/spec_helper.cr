require "spec"

# Set up test fixtures directory via environment variable
# This must be set BEFORE requiring claude_persona so CONFIG_DIR picks it up
SPEC_FIXTURES = Path[__DIR__] / "fixtures"
ENV["CLAUDE_PERSONA_CONFIG_DIR"] = SPEC_FIXTURES.to_s

# Claude config file locations (for MCP import testing)
SPEC_CLAUDE_FIXTURES = SPEC_FIXTURES / "claude"
ENV["CLAUDE_USER_CONFIG_PATH"] = (SPEC_CLAUDE_FIXTURES / "user-claude.json").to_s
ENV["CLAUDE_PROJECT_CONFIG_PATH"] = (SPEC_CLAUDE_FIXTURES / "project-claude.json").to_s

require "../src/claude_persona"
