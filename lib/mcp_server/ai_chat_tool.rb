require "mcp"

module McpServer
  class AiChatTool
    class << self
      def chat_tool
        {
          name: "ai_chat",
          description: "AI-powered natural language database assistant. Ask questions in plain English and get intelligent answers from your database.",
          inputSchema: {
            type: "object",
            properties: {
              question: {
                type: "string",
                description: "Your question about the database in natural language (e.g., 'How many accounts?', 'Show me recent orders', 'What are the top customers?')"
              },
              context: {
                type: "string",
                description: "Optional context or follow-up information",
                default: ""
              }
            },
            required: [ "question" ]
          }
        }
      end

      def chat(question:, context: "")
        begin
          Rails.logger.info "AI Chat: Processing question: #{question}"

          # Parse the natural language question
          parsed_query = parse_natural_language_question(question, context)

          if parsed_query[:success]
            # Execute the parsed query
            result = execute_parsed_query(parsed_query[:query], parsed_query[:type])

            if result[:success]
              # Format the response in a conversational way
              response = format_conversational_response(question, result[:data], parsed_query[:type])

              {
                success: true,
                question: question,
                answer: response,
                data: result[:data],
                query_type: parsed_query[:type],
                sql_query: parsed_query[:sql_query]
              }
            else
              {
                success: false,
                question: question,
                error: result[:error],
                suggestion: "Try rephrasing your question or ask about specific tables like 'account', 'order', 'invoice', etc."
              }
            end
          else
            {
              success: false,
              question: question,
              error: parsed_query[:error],
              suggestion: "I can help you with questions about accounts, orders, invoices, payments, and other database information. Try asking something like 'How many accounts do we have?' or 'Show me recent orders'."
            }
          end
        rescue => e
          Rails.logger.error "AI Chat error: #{e.message}"
          {
            success: false,
            question: question,
            error: e.message,
            suggestion: "Please try rephrasing your question or ask about specific database tables."
          }
        end
      end

      private

      def parse_natural_language_question(question, context)
        question_lower = question.downcase.strip

        # Account-related questions
        if question_lower.match?(/how many.*account|count.*account|total.*account|number.*account/)
          return {
            success: true,
            query: "SELECT COUNT(*) as count FROM account",
            type: "count",
            sql_query: "SELECT COUNT(*) as count FROM account"
          }
        end

        if question_lower.match?(/show.*account|list.*account|get.*account|find.*account/)
          return {
            success: true,
            query: "SELECT * FROM account LIMIT 10",
            type: "list",
            sql_query: "SELECT * FROM account LIMIT 10"
          }
        end

        # Order-related questions
        if question_lower.match?(/how many.*order|count.*order|total.*order|number.*order/)
          return {
            success: true,
            query: "SELECT COUNT(*) as count FROM \"order\"",
            type: "count",
            sql_query: "SELECT COUNT(*) as count FROM \"order\""
          }
        end

        if question_lower.match?(/show.*order|list.*order|get.*order|find.*order|recent.*order/)
          return {
            success: true,
            query: "SELECT * FROM \"order\" ORDER BY order_date DESC LIMIT 10",
            type: "list",
            sql_query: "SELECT * FROM \"order\" ORDER BY order_date DESC LIMIT 10"
          }
        end

        # Invoice-related questions
        if question_lower.match?(/how many.*invoice|count.*invoice|total.*invoice|number.*invoice/)
          return {
            success: true,
            query: "SELECT COUNT(*) as count FROM invoice",
            type: "count",
            sql_query: "SELECT COUNT(*) as count FROM invoice"
          }
        end

        if question_lower.match?(/show.*invoice|list.*invoice|get.*invoice|find.*invoice|recent.*invoice/)
          return {
            success: true,
            query: "SELECT * FROM invoice ORDER BY invoice_date DESC LIMIT 10",
            type: "list",
            sql_query: "SELECT * FROM invoice ORDER BY invoice_date DESC LIMIT 10"
          }
        end

        # Payment-related questions
        if question_lower.match?(/how many.*payment|count.*payment|total.*payment|number.*payment/)
          return {
            success: true,
            query: "SELECT COUNT(*) as count FROM payment_receipt",
            type: "count",
            sql_query: "SELECT COUNT(*) as count FROM payment_receipt"
          }
        end

        if question_lower.match?(/show.*payment|list.*payment|get.*payment|find.*payment|recent.*payment/)
          return {
            success: true,
            query: "SELECT * FROM payment_receipt ORDER BY created_date DESC LIMIT 10",
            type: "list",
            sql_query: "SELECT * FROM payment_receipt ORDER BY created_date DESC LIMIT 10"
          }
        end

        # Billing note questions
        if question_lower.match?(/how many.*billing|count.*billing|total.*billing|number.*billing/)
          return {
            success: true,
            query: "SELECT COUNT(*) as count FROM billing_note",
            type: "count",
            sql_query: "SELECT COUNT(*) as count FROM billing_note"
          }
        end

        # General table questions
        if question_lower.match?(/what.*table|list.*table|show.*table|available.*table/)
          return {
            success: true,
            query: "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name NOT LIKE 'pg_%' ORDER BY table_name",
            type: "list",
            sql_query: "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
          }
        end

        # If no pattern matches, try to extract table name and create a basic query
        table_name = extract_table_name(question_lower)
        if table_name
          return {
            success: true,
            query: "SELECT * FROM #{table_name} LIMIT 10",
            type: "list",
            sql_query: "SELECT * FROM #{table_name} LIMIT 10"
          }
        end

        {
          success: false,
          error: "I couldn't understand your question. Please try asking about accounts, orders, invoices, payments, or billing notes.",
          suggestion: "Try questions like 'How many accounts?', 'Show me recent orders', or 'List all tables'"
        }
      end

      def extract_table_name(question)
        # Common table name mappings
        table_mappings = {
          "account" => "account",
          "accounts" => "account",
          "order" => "order",
          "orders" => "order",
          "invoice" => "invoice",
          "invoices" => "invoice",
          "payment" => "payment_receipt",
          "payments" => "payment_receipt",
          "billing" => "billing_note",
          "billing_note" => "billing_note",
          "billing_notes" => "billing_note",
          "credit" => "account_credit",
          "credits" => "account_credit",
          "customer" => "account",
          "customers" => "account"
        }

        table_mappings.each do |keyword, table_name|
          return table_name if question.include?(keyword)
        end

        nil
      end

      def execute_parsed_query(query, type)
        begin
          Rails.logger.info "Executing query: #{query}"

          result = ActiveRecord::Base.connection.execute(query)
          rows = result.to_a

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

      def format_conversational_response(question, data, type)
        case type
        when "count"
          count = data.first&.dig("count") || data.first&.dig("account_count") || data.length
          "There are #{count} records in the database."

        when "list"
          if data.empty?
            "No records found."
          else
            count = data.length
            "I found #{count} records. Here are the details:"
          end

        else
          if data.empty?
            "No results found for your question."
          else
            "Here's what I found:"
          end
        end
      end
    end
  end
end
