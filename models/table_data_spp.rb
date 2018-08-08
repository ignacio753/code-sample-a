module Amd
  class TableDataSpp < TableDataBase
    # DB SP name
    self.function_name = 'table_data_spp'

    class << self
      private

      # Override parent method to add agregation param
      def args_from_params(query_params)
        [
          *criteria_args_from_params(query_params),
          *search_args_from_params(query_params),
          *pagination_args_from_params(query_params),
          *sorting_args_from_params(query_params),
          query_params[:aggregation_type_id].present? ? query_params[:aggregation_type_id] : 1
        ]
      end
    end
  end
end