# MCP Database Server

A Ruby on Rails application with an integrated Model Context Protocol (MCP) server that provides database interaction capabilities through the MCP protocol.

## Overview

This application includes a local MCP server that exposes database operations through STDIO transport, allowing MCP clients to interact with the PostgreSQL database. The server supports full read/write operations and follows Rails conventions while adhering to MCP protocol standards.

## Features

- **🤖 AI Chat Assistant**: Natural language database queries - ask questions in plain English
- **Database Query Execution**: Execute raw SQL queries (read/write operations)
- **Table Operations**: Query specific tables with filters and pagination
- **Schema Inspection**: Get detailed table schemas, relationships, and metadata
- **Resource Access**: Access database schema and relationship information
- **Rails Integration**: Full integration with Rails environment and ActiveRecord

## Prerequisites

- Ruby 3.0+
- Rails 8.0+
- PostgreSQL 12+
- MCP-compatible client

## Installation

1. **Set up RVM gemset** (if using RVM):

   ```bash
   # Create a dedicated gemset for this project
   rvm use ruby-3.4.7@mcp-db --create

   # Or use existing gemset
   rvm use ruby-3.4.7@mcp-db
   ```

2. **Install dependencies**:

   ```bash
   bundle install
   ```

3. **Set up the database**:

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Configure environment variables** (optional):

```bash
   export DB_USERNAME=your_username
   export DB_PASSWORD=your_password
   export DB_NAME=your_database_name
```

## Running the MCP Server

### Start the MCP Server

```bash
# Run the MCP server (STDIO mode)
./bin/mcp_server
```

The server will start in STDIO mode, reading JSON-RPC 2.0 requests from standard input and returning responses to standard output.

### Using with MCP Clients

The server can be used with any MCP-compatible client. Example configuration for MCP clients:

#### Claude Desktop Configuration

```json
{
  "mcpServers": {
    "credit-sales-db-mcp": {
      "command": "/Users/phomsang/.rvm/rubies/ruby-3.4.7/bin/ruby",
      "args": [
        "/Users/phomsang/Workspaces/cpp/fullstacks/mcp-db/bin/mcp_server"
      ],
      "cwd": "/Users/phomsang/Workspaces/cpp/fullstacks/mcp-db",
      "env": {
        "RAILS_ENV": "development",
        "PATH": "/Users/phomsang/.rvm/gems/ruby-3.4.7@mcp-db/bin:/Users/phomsang/.rvm/rubies/ruby-3.4.7/bin:/Users/phomsang/.rvm/bin:/usr/local/bin:/usr/bin:/bin",
        "GEM_HOME": "/Users/phomsang/.rvm/gems/ruby-3.4.7@mcp-db",
        "GEM_PATH": "/Users/phomsang/.rvm/gems/ruby-3.4.7@mcp-db:/Users/phomsang/.rvm/gems/ruby-3.4.7@global"
      }
    }
  }
}
```

#### Cursor Configuration

```json
{
  "mcpServers": {
    "credit-sales-db-mcp": {
      "command": "/Users/phomsang/.rvm/rubies/ruby-3.4.7/bin/ruby",
      "args": [
        "/Users/phomsang/Workspaces/cpp/fullstacks/mcp-db/bin/mcp_server"
      ],
      "cwd": "/Users/phomsang/Workspaces/cpp/fullstacks/mcp-db",
      "env": {
        "RAILS_ENV": "development",
        "PATH": "/Users/phomsang/.rvm/gems/ruby-3.4.7@mcp-db/bin:/Users/phomsang/.rvm/rubies/ruby-3.4.7/bin:/Users/phomsang/.rvm/bin:/usr/local/bin:/usr/bin:/bin",
        "GEM_HOME": "/Users/phomsang/.rvm/gems/ruby-3.4.7@mcp-db",
        "GEM_PATH": "/Users/phomsang/.rvm/gems/ruby-3.4.7@mcp-db:/Users/phomsang/.rvm/gems/ruby-3.4.7@global"
      }
    }
  }
}
```

**Note**: Update the paths in the configuration to match your system's RVM Ruby installation.

### Expected MCP Tools

Once connected, you should see these tools in your MCP client:

- `mcp_credit-sales-db-mcp_ai_chat` ⭐ **NEW!** - Ask questions in plain English
- `mcp_credit-sales-db-mcp_execute_query` - Execute raw SQL queries
- `mcp_credit-sales-db-mcp_list_tables` - List all database tables
- `mcp_credit-sales-db-mcp_describe_table` - Get detailed table schema
- `mcp_credit-sales-db-mcp_query_table` - Query specific tables with filters
- `mcp_credit-sales-db-mcp_get_table_data` - Get paginated table data

## Available Tools

### 🤖 AI Chat Assistant

**ai_chat** ⭐ **NEW!** - Natural language database queries

- Ask questions in plain English and get intelligent answers
- Automatically converts questions to SQL queries
- Provides conversational responses with data
- **Examples:**
  - "How many accounts?" → Returns account count
  - "Show me recent orders" → Lists recent orders
  - "What tables are available?" → Lists all tables
  - "How many invoices do we have?" → Returns invoice count

### Database Query Tools

1. **execute_query**

   - Execute raw SQL queries against the database
   - Supports both read and write operations
   - Parameters: `query` (required), `limit` (optional, default: 1000)

2. **query_table**

   - Query specific tables with filters and pagination
   - Parameters: `table_name` (required), `filters` (optional), `limit` (optional), `offset` (optional), `order_by` (optional)

3. **list_tables**

   - List all tables in the database
   - Parameters: `include_system_tables` (optional, default: false)

4. **describe_table**

   - Get detailed schema information for a specific table
   - Parameters: `table_name` (required)

5. **get_table_data**
   - Retrieve paginated data from a specific table
   - Parameters: `table_name` (required), `limit` (optional), `offset` (optional)

### Database Resources

1. **database://schema**

   - Complete database schema with all tables, columns, and relationships
   - MIME type: `application/json`

2. **database://tables**

   - List of all tables with basic information
   - MIME type: `application/json`

3. **database://relationships**
   - Foreign key relationships between tables
   - MIME type: `application/json`

## Configuration

The MCP server can be configured through `config/mcp_server.yml`:

```yaml
development:
  query_timeout: 30
  max_query_rows: 1000
  default_query_limit: 100
  default_page_size: 50
  max_page_size: 500
  log_level: "debug"
  log_queries: true
```

## Database Schema

The application includes a comprehensive database schema with the following main entities:

- **Account Management**: Customer accounts, addresses, contacts, credit information
- **Billing System**: Billing notes, invoices, credit notes, payment receipts
- **Order Processing**: Orders, payment conditions, transaction logs
- **Financial Operations**: Cheque payments, advance receipts, matching logs

## Security Considerations

⚠️ **Important**: This MCP server is designed for local development only and does not implement authentication. Do not expose it to public networks.

- No authentication mechanism (local development only)
- Input validation and SQL injection prevention
- Query timeout and row limits
- Configurable table access controls

## Development

### Running Tests

```bash
# Run the test suite
rails test

# Run specific test files
rails test test/models/account_test.rb
```

### Code Quality

```bash
# Run RuboCop
bundle exec rubocop

# Run Brakeman security scanner
bundle exec brakeman
```

### Database Operations

```bash
# Create and migrate database
rails db:create db:migrate

# Seed the database
rails db:seed

# Reset database
rails db:reset
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**

   - Verify PostgreSQL is running
   - Check database credentials in `config/database.yml`
   - Ensure database exists

2. **MCP Server Not Starting**

   - Check Rails environment is properly loaded
   - Verify all dependencies are installed
   - Check logs for specific error messages

3. **MCP Client Connection Issues**

   - **Ruby Version Mismatch**: Ensure MCP clients use the correct RVM Ruby version
   - **Path Issues**: Update configuration paths to match your RVM installation
   - **Environment Variables**: Verify GEM_HOME and GEM_PATH are set correctly
   - **Restart Required**: Restart MCP clients after configuration changes

4. **RVM-Specific Issues**

   - **Gemset**: Ensure you're using the correct gemset (e.g., `ruby-3.4.7@mcp-db`)
   - **Bundle Install**: Run `bundle install` in the project directory
   - **Ruby Path**: Verify the Ruby path in MCP configuration matches your RVM installation

5. **Query Execution Errors**
   - Verify SQL syntax
   - Check table and column names
   - Review query timeout settings

### Logs

The MCP server logs are integrated with Rails logging. Check:

```bash
# Development logs
tail -f log/development.log

# Production logs
tail -f log/production.log
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License.
