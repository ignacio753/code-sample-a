module FunctionRecord
  class MissingRequiredParameterError < RuntimeError; end

  class Base
    include ActiveRecord::Sanitization

    class << self
      attr_writer :function_name, :json_root, :columns, :id_attribute, :shard

      def find(*args)
        connection.execute(find_sql(*args), "FunctionRecord::#{name} Load")
      end

      def find_sql(*args)
        "SELECT #{columns}#{id_attribute} FROM #{function_name}(#{sql_safe_args(args)})"
      end

      def find_as_json(*args)
        sql = find_as_json_sql(*args)

        result = connection.execute(sql, "FunctionRecord::#{name} Load as JSON")

        "{\"#{json_root}\":#{result.first['root']}}"
      end

      def find_as_json_sql(*args)
        "WITH q AS (SELECT #{columns}#{id_attribute} FROM #{function_name}(#{sql_safe_args(args)})) " \
        "SELECT coalesce(json_agg(q), '[]'::json) AS root FROM q"
      end

      def find_by(query_params = {})
        validate_query_params!(query_params)
        args = args_from_params(query_params)
        find(*args)
      end

      def find_as_json_by(query_params)
        query_params ||= {}
        validate_query_params!(query_params)
        args = args_from_params(query_params)
        find_as_json(*args)
      end

      def select(column_array)
        @columns = column_array.join(',')
      end

      def function_name
        @function_name || name.underscore
      end

      def json_root
        @json_root || name.pluralize.underscore
      end

      def columns
        @columns.blank? ? '*' : @columns.join(', ')
      end

      def shard
        @shard || :report_data
      end

      def id_attribute
        return '' if @id_attribute.blank?
        ", #{@id_attribute} AS id"
      end

      private

      def connection
        ReportDatabase.connection
      end

      def sql_safe_args(args)
        types = []
        values = []
        args.each do |arg|
          if arg.nil?
            types << 'null'
          elsif arg.is_a?(String)
            types << "'%s'"
            values << arg
          elsif arg.is_a?(Integer)
            types << '%d'
            values << arg
          elsif arg.is_a?(TrueClass) || arg.is_a?(FalseClass)
            types << '%s'
            values << arg.to_s
          end
        end

        return '' if values.size == 0

        sanitize_sql_array([types.join(', ')].concat(values))
      end

      def args_from_params(_args)
        fail('Not implemented')
      end

      def validate_query_params!(query_params)
        required_query_params.each do |required_param|
          fail(MissingRequiredParameterError, "Required query parameter #{required_param} is missing or empty") if query_params[required_param].blank?
        end
      end

      ##
      # Override this method in your subclass to require specific parameters for `find_by` and `find_as_json_by`
      def required_query_params
        []
      end

    end
  end
end