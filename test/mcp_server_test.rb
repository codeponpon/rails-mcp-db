require "test_helper"

class McpServerTest < ActiveSupport::TestCase
  test "MCP server can be initialized" do
    assert_nothing_raised do
      require Rails.root.join("lib", "mcp_server", "simple_server")
      server = McpServer::SimpleServer.new
      assert_not_nil server
    end
  end

  test "database tools are available" do
    require Rails.root.join("lib", "mcp_server", "database_tools")

    # Test that tool definitions exist
    assert_not_nil McpServer::DatabaseTools.execute_query_tool
    assert_not_nil McpServer::DatabaseTools.query_table_tool
    assert_not_nil McpServer::DatabaseTools.list_tables_tool
    assert_not_nil McpServer::DatabaseTools.describe_table_tool
    assert_not_nil McpServer::DatabaseTools.get_table_data_tool
  end

  test "database resources are available" do
    require Rails.root.join("lib", "mcp_server", "database_resources")

    # Test that resource definitions exist
    assert_not_nil McpServer::DatabaseResources.schema_resource
    assert_not_nil McpServer::DatabaseResources.tables_resource
    assert_not_nil McpServer::DatabaseResources.relationships_resource
  end

  test "list_tables tool works" do
    require Rails.root.join("lib", "mcp_server", "database_tools")

    result = McpServer::DatabaseTools.list_tables
    assert result[:success]
    assert_not_nil result[:tables]
    assert result[:count] >= 0
  end

  test "describe_table tool works for account table" do
    require Rails.root.join("lib", "mcp_server", "database_tools")

    result = McpServer::DatabaseTools.describe_table(table_name: "account")
    assert result[:success]
    assert_not_nil result[:columns]
    assert result[:column_count] > 0
  end
end
