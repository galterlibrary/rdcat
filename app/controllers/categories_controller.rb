class CategoriesController < ApplicationController
  SUGGESTION_MODEL=::Category

  include SuggestionsConcerns
end
