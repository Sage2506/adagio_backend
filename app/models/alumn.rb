class Alumn < ApplicationRecord
  has_many :alumn_guardians
  has_many :guardians, through: :alumn_guardians
  has_many :assistances
  has_many :orders
  has_many :payments
  has_one :subscription
  before_create :set_defaults

  def set_defaults
    self.is_active = true
  end

  def plan_id
    subscription&.plan&.id
  end

  def subscription_id
    subscription&.id
  end

  ransacker :full_name, formatter: proc { |v| v.downcase } do |parent|
    Arel::Nodes::NamedFunction.new("LOWER", [
      Arel::Nodes::NamedFunction.new("CONCAT", [
        parent.table[:name],
        Arel::Nodes.build_quoted(" "),
        parent.table[:last_name]
      ])
    ])
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name last_name full_name birth_date email]
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
