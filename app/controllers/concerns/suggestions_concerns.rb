module SuggestionsConcerns
  extend ActiveSupport::Concern

  def suggestions
    respond_to do |format|
      size = 10
      size = params[:size].to_i if params[:size].present?
      if params[:query].present?
        query = params[:query].strip
        suggestions = self.class::SUGGESTION_MODEL.formatted_suggestions(
          query, size)
        format.json { render json: suggestions }
      else
        format.json { render json: [] }
      end
    end
  end
end
