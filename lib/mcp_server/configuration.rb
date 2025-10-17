require "yaml"

module McpServer
  class Configuration
    class << self
      def load
        config_path = Rails.root.join("config", "mcp_server.yml")

        if File.exist?(config_path)
          config = YAML.load_file(config_path, aliases: true)
          env_config = config[Rails.env] || config["default"] || {}
          new(env_config)
        else
          new(default_config)
        end
      end

      private

      def default_config
        {
          "query_timeout" => 30,
          "max_query_rows" => 1000,
          "default_query_limit" => 100,
          "default_page_size" => 50,
          "max_page_size" => 500,
          "log_level" => "info",
          "log_queries" => true,
          "log_errors" => true,
          "allowed_tables" => [],
          "blocked_tables" => [ "_prisma_migrations", "pg_%" ]
        }
      end
    end

    attr_reader :query_timeout, :max_query_rows, :default_query_limit,
                :default_page_size, :max_page_size, :log_level,
                :log_queries, :log_errors, :allowed_tables, :blocked_tables

    def initialize(config = {})
      @query_timeout = config["query_timeout"] || 30
      @max_query_rows = config["max_query_rows"] || 1000
      @default_query_limit = config["default_query_limit"] || 100
      @default_page_size = config["default_page_size"] || 50
      @max_page_size = config["max_page_size"] || 500
      @log_level = config["log_level"] || "info"
      @log_queries = config["log_queries"] || true
      @log_errors = config["log_errors"] || true
      @allowed_tables = config["allowed_tables"] || []
      @blocked_tables = config["blocked_tables"] || [ "_prisma_migrations", "pg_%" ]
    end

    def table_allowed?(table_name)
      return false if blocked_tables.any? { |pattern| table_name.match?(pattern) }
      return true if allowed_tables.empty?

      allowed_tables.include?(table_name)
    end

    def validate_query_limit(limit)
      [ limit.to_i, max_query_rows ].min
    end

    def validate_page_size(size)
      [ size.to_i, max_page_size ].min
    end
  end
end
