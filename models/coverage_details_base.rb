class TableDataBase < FunctionRecord::Base

  class << self
    private
    # Format the query params here, then pass to DB SP as input params []
    def args_from_params(query_params)
      [
        *criteria_args_from_params(query_params),
        *nomen_args_from_params(query_params),
        *search_args_from_params(query_params),
        *pagination_args_from_params(query_params),
        *sorting_args_from_params(query_params)
      ]
    end

    # Criteria report params
    def criteria_args_from_params(query_params)
      [
        query_params[:criteria_report_id]
      ]
    end

    # Nomenclature set params
    def nomen_args_from_params(query_params)
      [
        query_params[:nomenclature_set_ids].present? ? query_params[:nomenclature_set_ids] : '',
      ]
    end

    # Search params
    def search_args_from_params(query_params)
      [
        query_params[:search_term_text].present? ? query_params[:search_term_text].gsub("'","''") : ''
      ]
    end

    # Pagination params
    def pagination_args_from_params(query_params)
      [
        query_params[:row_result_per_page].present? ? query_params[:row_result_per_page].to_i : 50,
        query_params[:row_result_page_num].present? ? query_params[:row_result_page_num].to_i : 1
      ]
    end

    # Sorting logic params
    def sorting_args_from_params(query_params)
      [
        query_params[:sorting_type_id].present? ? query_params[:sorting_type_id].to_i : 0,
        query_params[:sort_id].present? ? query_params[:sort_id] : 0,
        query_params[:sort_order].present? ? query_params[:sort_order] : 'asc',
        query_params[:sort_column_object_id].present? ? query_params[:sort_column_object_id] : 0
      ]
    end

    # If there is any required params
    def required_query_params
      [
        :criteria_report_id
      ]
    end
  end
end