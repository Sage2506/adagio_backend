class Plan < ApplicationRecord
  has_many :plan_disciplines
  has_many :plans, through: :plan_disciplines
  has_many :subscriptions
  before_create :set_defaults

  def set_defaults
    self.is_active = true
  end

   def self.ransackable_attributes(auth_object = nil)
    %w[name] + _ransackers.keys
  end

  # `ransackable_associations` returns the names
  # of searchable associations as an array of strings.
  #
  def self.ransackable_associations(auth_object = nil)
    %w[]
  end

  # `ransortable_attributes` by default returns the names
  # of all attributes available for sorting as an array of strings.
  #
  def self.ransortable_attributes(auth_object = nil)
    ransackable_attributes(auth_object)
  end

  # `ransackable_scopes` by default returns an empty array
  # i.e. no class methods/scopes are authorized.
  # For overriding with an allowlist, return an array of *symbols*.
  #
  def self.ransackable_scopes(auth_object = nil)
    []
  end
end
