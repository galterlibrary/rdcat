module ApplicationHelper

  def can_show?(record)
    policy(record).show?
  end

  def can_create?(record)
    current_user && policy(record).create?
  end

  def can_edit?(record)
    current_user && policy(record).edit?
  end

  def can_destroy?(record)
    current_user && policy(record).destroy?
  end

end
