class DatasetPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    true
  end

  def update?
    admin? || user_associated_with_record?
  end

  def edit?
    admin? || user_associated_with_record?
  end

  def destroy?
    admin? || user_associated_with_record?
  end

  def user_associated_with_record?
    record.author == user || record.maintainer == user 
  end
  private :user_associated_with_record?
end