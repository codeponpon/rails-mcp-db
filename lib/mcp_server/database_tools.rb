require "mcp"

module McpServer
  class DatabaseTools
    class << self
      def execute_query_tool
        {
          name: "execute_query",
          description: "Execute raw SQL queries against the database (read/write operations)",
          inputSchema: {
            type: "object",
            properties: {
              query: {
                type: "string",
                description: "SQL query to execute"
              },
              limit: {
                type: "integer",
                description: "Maximum number of rows to return (default: 1000)",
                default: 1000
              }
            },
            required: [ "query" ]
          }
        }
      end

      def query_table_tool
        {
          name: "query_table",
          description: "Query a specific table with optional filters and pagination",
          inputSchema: {
            type: "object",
            properties: {
              table_name: {
                type: "string",
                description: "Name of the table to query"
              },
              filters: {
                type: "object",
                description: "Key-value pairs for WHERE clause filters"
              },
              limit: {
                type: "integer",
                description: "Maximum number of rows to return (default: 100)",
                default: 100
              },
              offset: {
                type: "integer",
                description: "Number of rows to skip (default: 0)",
                default: 0
              },
              order_by: {
                type: "string",
                description: "Column name to order by"
              }
            },
            required: [ "table_name" ]
          }
        }
      end

      def list_tables_tool
        {
          name: "list_tables",
          description: "List all tables in the database with basic information",
          inputSchema: {
            type: "object",
            properties: {
              include_system_tables: {
                type: "boolean",
                description: "Include system tables (default: false)",
                default: false
              }
            }
          }
        }
      end

      def describe_table_tool
        {
          name: "describe_table",
          description: "Get detailed schema information for a specific table",
          inputSchema: {
            type: "object",
            properties: {
              table_name: {
                type: "string",
                description: "Name of the table to describe"
              }
            },
            required: [ "table_name" ]
          }
        }
      end

      def get_table_data_tool
        {
          name: "get_table_data",
          description: "Retrieve paginated data from a specific table",
          inputSchema: {
            type: "object",
            properties: {
              table_name: {
                type: "string",
                description: "Name of the table to query"
              },
              limit: {
                type: "integer",
                description: "Maximum number of rows to return (default: 50)",
                default: 50
              },
              offset: {
                type: "integer",
                description: "Number of rows to skip (default: 0)",
                default: 0
              }
            },
            required: [ "table_name" ]
          }
        }
      end

      # Tool execution methods
      def execute_query(query:, limit: 1000)
        begin
          Rails.logger.info "Executing query: #{query}"

          # Execute the query using ActiveRecord
          result = ActiveRecord::Base.connection.execute(query)

          # Convert result to array of hashes
          if result.respond_to?(:to_a)
            rows = result.to_a.first(limit)
          else
            rows = result.first(limit)
          end

          {
            success: true,
            data: rows,
            row_count: rows.length,
            query: query
          }
        rescue => e
          Rails.logger.error "Query execution failed: #{e.message}"
          {
            success: false,
            error: e.message,
            query: query
          }
        end
      end

      def query_table(table_name:, filters: {}, limit: 100, offset: 0, order_by: nil)
        begin
          Rails.logger.info "Querying table: #{table_name} with filters: #{filters}"

          # Build the query
          query = ActiveRecord::Base.connection.quote_table_name(table_name)
          where_clause = build_where_clause(filters)
          order_clause = order_by ? "ORDER BY #{ActiveRecord::Base.connection.quote_column_name(order_by)}" : ""

          sql = "SELECT * FROM #{query} #{where_clause} #{order_clause} LIMIT #{limit} OFFSET #{offset}"

          result = ActiveRecord::Base.connection.execute(sql)
          rows = result.to_a

          {
            success: true,
            data: rows,
            row_count: rows.length,
            table_name: table_name,
            filters: filters,
            limit: limit,
            offset: offset
          }
        rescue => e
          Rails.logger.error "Table query failed: #{e.message}"
          {
            success: false,
            error: e.message,
            table_name: table_name
          }
        end
      end

      def list_tables(include_system_tables: false)
        begin
          Rails.logger.info "Listing tables (include_system_tables: #{include_system_tables})"

          # Get table names from information_schema
          sql = <<~SQL
            SELECT#{' '}
              table_name,
              table_type,
              table_schema
            FROM information_schema.tables#{' '}
            WHERE table_schema = 'public'
          SQL

          unless include_system_tables
            sql += " AND table_name NOT LIKE 'pg_%' AND table_name NOT LIKE '_prisma_%'"
          end

          sql += " ORDER BY table_name"

          result = ActiveRecord::Base.connection.execute(sql)
          tables = result.to_a

          {
            success: true,
            tables: tables,
            count: tables.length,
            include_system_tables: include_system_tables
          }
        rescue => e
          Rails.logger.error "List tables failed: #{e.message}"
          {
            success: false,
            error: e.message
          }
        end
      end

      def describe_table(table_name:)
        begin
          Rails.logger.info "Describing table: #{table_name}"

          # Get column information
          columns_sql = <<~SQL
            SELECT#{' '}
              column_name,
              data_type,
              is_nullable,
              column_default,
              character_maximum_length,
              numeric_precision,
              numeric_scale
            FROM information_schema.columns#{' '}
            WHERE table_name = #{ActiveRecord::Base.connection.quote(table_name)}
            AND table_schema = 'public'
            ORDER BY ordinal_position
          SQL

          columns_result = ActiveRecord::Base.connection.execute(columns_sql)
          columns = columns_result.to_a

          # Get foreign key information
          fk_sql = <<~SQL
            SELECT#{' '}
              kcu.column_name,
              ccu.table_name AS foreign_table_name,
              ccu.column_name AS foreign_column_name,
              tc.constraint_name
            FROM information_schema.table_constraints AS tc#{' '}
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY'#{' '}
            AND tc.table_name = #{ActiveRecord::Base.connection.quote(table_name)}
          SQL

          fk_result = ActiveRecord::Base.connection.execute(fk_sql)
          foreign_keys = fk_result.to_a

          # Get index information
          index_sql = <<~SQL
            SELECT#{' '}
              indexname,
              indexdef
            FROM pg_indexes#{' '}
            WHERE tablename = #{ActiveRecord::Base.connection.quote(table_name)}
            AND schemaname = 'public'
          SQL

          index_result = ActiveRecord::Base.connection.execute(index_sql)
          indexes = index_result.to_a

          {
            success: true,
            table_name: table_name,
            columns: columns,
            foreign_keys: foreign_keys,
            indexes: indexes,
            column_count: columns.length
          }
        rescue => e
          Rails.logger.error "Describe table failed: #{e.message}"
          {
            success: false,
            error: e.message,
            table_name: table_name
          }
        end
      end

      def get_table_data(table_name:, limit: 50, offset: 0)
        begin
          Rails.logger.info "Getting table data: #{table_name} (limit: #{limit}, offset: #{offset})"

          sql = "SELECT * FROM #{ActiveRecord::Base.connection.quote_table_name(table_name)} LIMIT #{limit} OFFSET #{offset}"
          result = ActiveRecord::Base.connection.execute(sql)
          rows = result.to_a

          {
            success: true,
            data: rows,
            row_count: rows.length,
            table_name: table_name,
            limit: limit,
            offset: offset
          }
        rescue => e
          Rails.logger.error "Get table data failed: #{e.message}"
          {
            success: false,
            error: e.message,
            table_name: table_name
          }
        end
      end

      private

      def build_where_clause(filters)
        return "" if filters.empty?

        conditions = filters.map do |column, value|
          quoted_column = ActiveRecord::Base.connection.quote_column_name(column)
          quoted_value = ActiveRecord::Base.connection.quote(value)
          "#{quoted_column} = #{quoted_value}"
        end

        "WHERE #{conditions.join(' AND ')}"
      end
    end
  end
end
