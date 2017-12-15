class FastSubjectsController < ApplicationController
  SUGGESTION_MODEL=::FastSubject

  include SuggestionsConcerns
end
