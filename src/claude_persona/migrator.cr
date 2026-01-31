module ClaudePersona
  module Migrator
    # Result of a migration attempt
    enum Result
      AlreadyCurrent # No upgrade needed
      Upgraded       # Successfully upgraded
      Failed         # Migration failed (backup preserved)
      ReadOnly       # File is read-only
    end

    # Check if persona needs upgrade
    def self.needs_upgrade?(config : PersonaConfig) : Bool
      effective_version(config) != VERSION
    end

    # Get effective version (nil treated as "0.0.0")
    def self.effective_version(config : PersonaConfig) : String
      config.version || "0.0.0"
    end

    # Upgrade persona at path, returns result
    def self.upgrade(name : String, config : PersonaConfig, path : Path) : Result
      return Result::AlreadyCurrent unless needs_upgrade?(config)

      # Check if file is writable
      unless File::Info.writable?(path)
        return Result::ReadOnly
      end

      # Create backup
      backup_path = Path.new("#{path}.bak")
      File.copy(path, backup_path)

      begin
        # Run migrations (none exist yet - just stamp version)
        run_migrations(config, path)

        # Remove backup on success
        File.delete(backup_path) if File.exists?(backup_path)

        Result::Upgraded
      rescue ex
        # Restore from backup on failure
        if File.exists?(backup_path)
          File.copy(backup_path, path)
          File.delete(backup_path)
        end
        Result::Failed
      end
    end

    # Run all applicable migrations in sequence
    private def self.run_migrations(config : PersonaConfig, path : Path)
      from_version = effective_version(config)

      # Future migrations would go here:
      #
      # if compare_versions(from_version, "0.2.0") < 0
      #   config = migrate_to_0_2_0(config)
      # end
      # if compare_versions(from_version, "0.3.0") < 0
      #   config = migrate_to_0_3_0(config)
      # end

      # For now: just stamp with current version
      TomlWriter.write(path, config, VERSION)
    end

    # Compare semantic versions: -1 if a < b, 0 if equal, 1 if a > b
    # Used for future migration ordering
    def self.compare_versions(a : String, b : String) : Int32
      a_parts = a.split(".").map(&.to_i)
      b_parts = b.split(".").map(&.to_i)

      # Pad to same length
      max_len = [a_parts.size, b_parts.size].max
      while a_parts.size < max_len
        a_parts << 0
      end
      while b_parts.size < max_len
        b_parts << 0
      end

      a_parts.zip(b_parts).each do |av, bv|
        return -1 if av < bv
        return 1 if av > bv
      end

      0
    end
  end
end
