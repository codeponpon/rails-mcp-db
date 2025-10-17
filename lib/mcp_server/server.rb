require "mcp"
require_relative "database_tools"
require_relative "database_resources"
require_relative "configuration"

module McpServer
  class Server
    def initialize
      @config = Configuration.load
      @server = MCP::Server.new(
        name: "mcp-database-server",
        version: "1.0.0"
      )

      setup_tools
      setup_resources
      setup_logging
    end

    def run
      # Initialize Rails environment
      require_relative "../../config/environment"

      Rails.logger.info "Starting MCP Database Server..."

      # Start STDIO transport
      transport = MCP::Transport::Stdio.new
      @server.run(transport)
    rescue => e
      Rails.logger.error "MCP Server error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    private

    def setup_tools
      # Register database tools
      @server.add_tool("execute_query", DatabaseTools.execute_query_tool)
      @server.add_tool("query_table", DatabaseTools.query_table_tool)
      @server.add_tool("list_tables", DatabaseTools.list_tables_tool)
      @server.add_tool("describe_table", DatabaseTools.describe_table_tool)
      @server.add_tool("get_table_data", DatabaseTools.get_table_data_tool)
    end

    def setup_resources
      # Register database resources
      @server.add_resource("database://schema", DatabaseResources.schema_resource)
      @server.add_resource("database://tables", DatabaseResources.tables_resource)
      @server.add_resource("database://relationships", DatabaseResources.relationships_resource)
    end

    def setup_logging
      # Configure logging for MCP server
      Rails.logger.info "MCP Database Server initialized with #{@server.tools.count} tools and #{@server.resources.count} resources"
      Rails.logger.info "Configuration: query_timeout=#{@config.query_timeout}s, max_rows=#{@config.max_query_rows}"
    end
  end
end
