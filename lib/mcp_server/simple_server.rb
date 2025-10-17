require "mcp"
require_relative "database_tools"
require_relative "database_resources"
require_relative "ai_chat_tool"
require_relative "configuration"

module McpServer
  class SimpleServer
    def initialize
      @config = Configuration.load
      @server = MCP::Server.new(
        name: "mcp-database-server",
        version: "1.0.0"
      )

      setup_logging
    end

    def run
      # Initialize Rails environment
      require_relative "../../config/environment"

      Rails.logger.info "Starting MCP Database Server..."

      # Create a simple STDIO-based server
      loop do
        begin
          # Read JSON-RPC request from STDIN
          request_line = STDIN.gets
          next unless request_line

          request = JSON.parse(request_line.strip)
          response = handle_request(request)

          # Send JSON-RPC response to STDOUT
          puts JSON.generate(response)
          STDOUT.flush
        rescue JSON::ParserError => e
          Rails.logger.error "JSON parse error: #{e.message}"
          error_response = {
            jsonrpc: "2.0",
            id: nil,
            error: {
              code: -32700,
              message: "Parse error"
            }
          }
          puts JSON.generate(error_response)
          STDOUT.flush
        rescue => e
          Rails.logger.error "Server error: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          error_response = {
            jsonrpc: "2.0",
            id: nil,
            error: {
              code: -32603,
              message: "Internal error"
            }
          }
          puts JSON.generate(error_response)
          STDOUT.flush
        end
      end
    rescue => e
      Rails.logger.error "MCP Server error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    private

    def handle_request(request)
      method = request["method"]
      params = request["params"] || {}
      id = request["id"]

      case method
      when "initialize"
        handle_initialize(id)
      when "tools/list"
        handle_tools_list(id)
      when "tools/call"
        handle_tool_call(id, params)
      when "resources/list"
        handle_resources_list(id)
      when "resources/read"
        handle_resource_read(id, params)
      else
        {
          jsonrpc: "2.0",
          id: id,
          error: {
            code: -32601,
            message: "Method not found"
          }
        }
      end
    end

    def handle_initialize(id)
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          protocolVersion: "2024-11-05",
          capabilities: {
            tools: {},
            resources: {}
          },
          serverInfo: {
            name: "mcp-database-server",
            version: "1.0.0"
          }
        }
      }
    end

      def handle_tools_list(id)
        {
          jsonrpc: "2.0",
          id: id,
          result: {
            tools: [
              AiChatTool.chat_tool,
              DatabaseTools.execute_query_tool,
              DatabaseTools.query_table_tool,
              DatabaseTools.list_tables_tool,
              DatabaseTools.describe_table_tool,
              DatabaseTools.get_table_data_tool
            ]
          }
        }
      end

    def handle_tool_call(id, params)
      tool_name = params["name"]
      arguments = params["arguments"] || {}

      result = case tool_name
      when "ai_chat"
        AiChatTool.chat(**arguments.symbolize_keys)
      when "execute_query"
        DatabaseTools.execute_query(**arguments.symbolize_keys)
      when "query_table"
        DatabaseTools.query_table(**arguments.symbolize_keys)
      when "list_tables"
        DatabaseTools.list_tables(**arguments.symbolize_keys)
      when "describe_table"
        DatabaseTools.describe_table(**arguments.symbolize_keys)
      when "get_table_data"
        DatabaseTools.get_table_data(**arguments.symbolize_keys)
      else
        { success: false, error: "Unknown tool: #{tool_name}" }
      end

      {
        jsonrpc: "2.0",
        id: id,
        result: {
          content: [
            {
              type: "text",
              text: JSON.generate(result)
            }
          ]
        }
      }
    end

    def handle_resources_list(id)
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          resources: [
            DatabaseResources.schema_resource,
            DatabaseResources.tables_resource,
            DatabaseResources.relationships_resource
          ]
        }
      }
    end

    def handle_resource_read(id, params)
      uri = params["uri"]

      content = case uri
      when "database://schema"
        DatabaseResources.get_schema_content
      when "database://tables"
        DatabaseResources.get_tables_content
      when "database://relationships"
        DatabaseResources.get_relationships_content
      else
        { error: "Unknown resource: #{uri}" }.to_json
      end

      {
        jsonrpc: "2.0",
        id: id,
        result: {
          contents: [
            {
              uri: uri,
              mimeType: "application/json",
              text: content
            }
          ]
        }
      }
    end

    def setup_logging
      Rails.logger.info "MCP Database Server initialized"
      Rails.logger.info "Configuration: query_timeout=#{@config.query_timeout}s, max_rows=#{@config.max_query_rows}"
    end
  end
end
