#!/usr/bin/env ruby

# Example MCP Client Usage
# This script demonstrates how to interact with the MCP Database Server

require 'json'
require 'open3'

class McpClientExample
  def initialize
    @server_path = File.expand_path('../bin/mcp_server', __dir__)
  end

  def run
    puts "MCP Database Server Client Example"
    puts "=================================="

    # Start the MCP server
    puts "\nStarting MCP server..."
    start_server

    # Example 1: List tables
    puts "\n1. Listing all tables:"
    list_tables

    # Example 2: Describe a table
    puts "\n2. Describing 'account' table:"
    describe_table("account")

    # Example 3: Query table data
    puts "\n3. Getting data from 'account' table (first 5 rows):"
    get_table_data("account", limit: 5)

    # Example 4: Execute a custom query
    puts "\n4. Executing custom query:"
    execute_query("SELECT COUNT(*) as total_accounts FROM account")

    puts "\nExample completed!"
  end

  private

  def start_server
    # This would normally start the server process
    # For this example, we'll just show the command
    puts "Command: #{@server_path}"
  end

  def send_mcp_request(method, params = {})
    request = {
      jsonrpc: "2.0",
      id: rand(1000),
      method: method,
      params: params
    }

    puts "Sending request: #{JSON.pretty_generate(request)}"

    # In a real implementation, this would send the request to the MCP server
    # and receive the response via STDIO
    puts "Response would be received here..."
  end

  def list_tables
    send_mcp_request("tools/call", {
      name: "list_tables",
      arguments: {
        include_system_tables: false
      }
    })
  end

  def describe_table(table_name)
    send_mcp_request("tools/call", {
      name: "describe_table",
      arguments: {
        table_name: table_name
      }
    })
  end

  def get_table_data(table_name, limit: 10)
    send_mcp_request("tools/call", {
      name: "get_table_data",
      arguments: {
        table_name: table_name,
        limit: limit,
        offset: 0
      }
    })
  end

  def execute_query(query)
    send_mcp_request("tools/call", {
      name: "execute_query",
      arguments: {
        query: query,
        limit: 1000
      }
    })
  end
end

# Run the example if this file is executed directly
if __FILE__ == $0
  client = McpClientExample.new
  client.run
end
