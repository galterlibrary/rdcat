class DistributionPolicy < ApplicationPolicy
  def index?
    admin? || user_associated_with_record? || is_public?
  end

  def show?
    admin? || user_associated_with_record? || is_public?
  end

  def download?
    admin? || user_associated_with_record? || is_public?
  end

  def create?
    admin? || user_associated_with_record?
  end

  def new?
    admin? || user_associated_with_record?
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
    record.dataset.author == user || record.dataset.maintainer == user 
  end
  private :user_associated_with_record?

  def is_public?
    record.dataset.visibility == Dataset::PUBLIC
  end
  private :is_public?

  def is_private?
    record.dataset.visibility == Dataset::PRIVATE
  end
  private :is_private?
end
