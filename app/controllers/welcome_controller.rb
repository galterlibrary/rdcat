class WelcomeController < ApplicationController
  def index
    @categories = DatasetPolicy::Scope.new(
      current_user, Dataset
    ).resolve.chosen_categories.shuffle
  end
end
