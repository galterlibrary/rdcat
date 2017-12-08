class UserPolicy < AdminPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    true
  end

  def create?
    self_or_admin?
  end

  def edit?
    self_or_admin?
  end

  def update?
    self_or_admin?
  end

  def destroy?
    self_or_admin?
  end

  private

  def self_or_admin?
    record == user || admin?
  end
end
