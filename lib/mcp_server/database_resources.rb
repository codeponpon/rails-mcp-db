require "mcp"

module McpServer
  class DatabaseResources
    class << self
      def schema_resource
        {
          uri: "database://schema",
          name: "Database Schema",
          description: "Complete database schema with all tables, columns, and relationships",
          mimeType: "application/json"
        }
      end

      def tables_resource
        {
          uri: "database://tables",
          name: "Database Tables",
          description: "List of all tables in the database with basic information",
          mimeType: "application/json"
        }
      end

      def relationships_resource
        {
          uri: "database://relationships",
          name: "Database Relationships",
          description: "Foreign key relationships between tables",
          mimeType: "application/json"
        }
      end

      # Resource content methods
      def get_schema_content
        begin
          Rails.logger.info "Generating database schema content"

          # Get all tables
          tables_sql = <<~SQL
            SELECT#{' '}
              table_name,
              table_type
            FROM information_schema.tables#{' '}
            WHERE table_schema = 'public'
            AND table_name NOT LIKE 'pg_%'
            AND table_name NOT LIKE '_prisma_%'
            ORDER BY table_name
          SQL

          tables_result = ActiveRecord::Base.connection.execute(tables_sql)
          tables = tables_result.to_a

          # Get detailed information for each table
          schema = {
            database_name: ActiveRecord::Base.connection.current_database,
            tables: {},
            relationships: get_relationships,
            generated_at: Time.current.iso8601
          }

          tables.each do |table_info|
            table_name = table_info["table_name"]
            schema[:tables][table_name] = get_table_schema(table_name)
          end

          schema.to_json
        rescue => e
          Rails.logger.error "Schema generation failed: #{e.message}"
          { error: e.message }.to_json
        end
      end

      def get_tables_content
        begin
          Rails.logger.info "Generating tables content"

          tables_sql = <<~SQL
            SELECT#{' '}
              table_name,
              table_type,
              (SELECT COUNT(*) FROM information_schema.columns#{' '}
               WHERE table_name = t.table_name AND table_schema = 'public') as column_count
            FROM information_schema.tables t
            WHERE table_schema = 'public'
            AND table_name NOT LIKE 'pg_%'
            AND table_name NOT LIKE '_prisma_%'
            ORDER BY table_name
          SQL

          result = ActiveRecord::Base.connection.execute(tables_sql)
          tables = result.to_a

          {
            database_name: ActiveRecord::Base.connection.current_database,
            tables: tables,
            count: tables.length,
            generated_at: Time.current.iso8601
          }.to_json
        rescue => e
          Rails.logger.error "Tables content generation failed: #{e.message}"
          { error: e.message }.to_json
        end
      end

      def get_relationships_content
        begin
          Rails.logger.info "Generating relationships content"

          relationships = get_relationships

          {
            database_name: ActiveRecord::Base.connection.current_database,
            relationships: relationships,
            count: relationships.length,
            generated_at: Time.current.iso8601
          }.to_json
        rescue => e
          Rails.logger.error "Relationships content generation failed: #{e.message}"
          { error: e.message }.to_json
        end
      end

      private

      def get_table_schema(table_name)
        begin
          # Get columns
          columns_sql = <<~SQL
            SELECT#{' '}
              column_name,
              data_type,
              is_nullable,
              column_default,
              character_maximum_length,
              numeric_precision,
              numeric_scale,
              ordinal_position
            FROM information_schema.columns#{' '}
            WHERE table_name = #{ActiveRecord::Base.connection.quote(table_name)}
            AND table_schema = 'public'
            ORDER BY ordinal_position
          SQL

          columns_result = ActiveRecord::Base.connection.execute(columns_sql)
          columns = columns_result.to_a

          # Get primary key
          pk_sql = <<~SQL
            SELECT kcu.column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            WHERE tc.constraint_type = 'PRIMARY KEY'
            AND tc.table_name = #{ActiveRecord::Base.connection.quote(table_name)}
            AND tc.table_schema = 'public'
          SQL

          pk_result = ActiveRecord::Base.connection.execute(pk_sql)
          primary_keys = pk_result.to_a.map { |row| row["column_name"] }

          # Get foreign keys
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
            AND tc.table_schema = 'public'
          SQL

          fk_result = ActiveRecord::Base.connection.execute(fk_sql)
          foreign_keys = fk_result.to_a

          # Get indexes
          index_sql = <<~SQL
            SELECT#{' '}
              indexname,
              indexdef,
              indisunique,
              indisprimary
            FROM pg_indexes pi
            JOIN pg_class pc ON pc.relname = pi.indexname
            JOIN pg_index pgi ON pgi.indexrelid = pc.oid
            WHERE pi.tablename = #{ActiveRecord::Base.connection.quote(table_name)}
            AND pi.schemaname = 'public'
          SQL

          index_result = ActiveRecord::Base.connection.execute(index_sql)
          indexes = index_result.to_a

          {
            table_name: table_name,
            columns: columns,
            primary_keys: primary_keys,
            foreign_keys: foreign_keys,
            indexes: indexes,
            column_count: columns.length
          }
        rescue => e
          Rails.logger.error "Table schema generation failed for #{table_name}: #{e.message}"
          { error: e.message, table_name: table_name }
        end
      end

      def get_relationships
        begin
          relationships_sql = <<~SQL
            SELECT#{' '}
              tc.table_name,
              kcu.column_name,
              ccu.table_name AS foreign_table_name,
              ccu.column_name AS foreign_column_name,
              tc.constraint_name,
              rc.update_rule,
              rc.delete_rule
            FROM information_schema.table_constraints AS tc#{' '}
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
            JOIN information_schema.referential_constraints AS rc
              ON tc.constraint_name = rc.constraint_name
              AND tc.table_schema = rc.constraint_schema
            WHERE tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema = 'public'
            ORDER BY tc.table_name, kcu.column_name
          SQL

          result = ActiveRecord::Base.connection.execute(relationships_sql)
          relationships = result.to_a

          # Group relationships by table
          grouped_relationships = {}
          relationships.each do |rel|
            table_name = rel["table_name"]
            grouped_relationships[table_name] ||= []
            grouped_relationships[table_name] << {
              column: rel["column_name"],
              references_table: rel["foreign_table_name"],
              references_column: rel["foreign_column_name"],
              constraint_name: rel["constraint_name"],
              update_rule: rel["update_rule"],
              delete_rule: rel["delete_rule"]
            }
          end

          grouped_relationships
        rescue => e
          Rails.logger.error "Relationships generation failed: #{e.message}"
          {}
        end
      end
    end
  end
end
