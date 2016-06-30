class WelcomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @categories = Dataset.chosen_categories
  end
end
