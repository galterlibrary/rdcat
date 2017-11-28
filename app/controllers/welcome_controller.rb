class WelcomeController < ApplicationController
  def index
    @categories = Dataset.chosen_categories.shuffle
  end
end
