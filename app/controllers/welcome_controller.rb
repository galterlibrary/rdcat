class WelcomeController < ApplicationController
  def index
    @categories = Dataset.chosen_categories
  end
end
