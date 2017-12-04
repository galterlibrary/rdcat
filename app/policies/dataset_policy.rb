class DatasetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if admin?
        scope.all
      else
        scope.where(visibility: Dataset::PUBLIC).or(
          scope.where(author: user).where.not(author: nil)
        ).or(
          scope.where(maintainer: user)
        )
      end
    end
  end

  def index?
    true
  end

  def search?
    true
  end

  def show?
    admin? || user_associated_with_record? || is_public?
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

  def mint_doi?
    admin? || user_associated_with_record?
  end

  def user_associated_with_record?
    record.author == user || record.maintainer == user 
  end
  private :user_associated_with_record?

  def is_public?
    record.visibility == Dataset::PUBLIC
  end
  private :is_public?

  def is_private?
    record.visibility == Dataset::PRIVATE
  end
  private :is_private?
end
