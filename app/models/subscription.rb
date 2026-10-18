class Subscription < ApplicationRecord
  SPANISH_MONTHS = %w[
    enero febrero marzo abril mayo junio
    julio agosto septiembre octubre noviembre diciembre
  ].freeze

  belongs_to :plan
  belongs_to :alumn
  has_many :subscription_payments
  has_many :payments, through: :subscription_payments
  before_create :set_subscribed_at_if_blank
  before_create :set_defaults
  enum :status, [ :active, :cancelled, :expired ]
  scope :active, -> { where("status = 0") }
  validates :custom_price, numericality: { greater_than: 0 }, allow_nil: true

  def set_defaults
    self.status = 0
    self.due_date = calculate_due_date
  end

  # Regla de negocio: el día de subscribed_at define el mes/día de vencimiento
  def calculate_due_date
    date = (subscribed_at || Date.today).to_date
    case date.day
    when 1..7
      date.beginning_of_month
    when 8..21
      date.change(day: 15)
    when 22..31
      date.next_month.beginning_of_month
    end
  end

  def fully_paid?
    paid_amount >= effective_price
  end

  def remaining_balance
    [ effective_price - paid_amount, 0 ].max
  end

  def payment_percentage
    (paid_amount / effective_price * 100).round(2)
  end

  def whatsapp_reminder_message
    guardian_first_name = whatsapp_reminder_guardian&.name.to_s.split.first.to_s.capitalize
    alumn_first_name = alumn.name.to_s.split.first.to_s.capitalize
    current_month = SPANISH_MONTHS[Date.current.month - 1]

    <<~MESSAGE.chomp
      ¡Hola, #{guardian_first_name}! Esperamos que estés muy bien.
      Te escribimos para recordarte que la fecha límite de pago para la mensualidad de #{alumn_first_name} del mes de #{current_month.capitalize} fue el día #{due_date.mday + 4} (incluyendo los 5 días de gracia).
      Te pedimos amablemente que nos ayudes regularizando el pago a la brevedad. 📝
      Nunca negaremos el acceso a las alumnas, pero su puntualidad nos permite mantener la calidad de nuestras clases.
      ¡Muchas gracias por tu apoyo! 💜
      Quedamos atentos por si tienes alguna duda.😊
      Favor de no responder a este mensaje; es un aviso automático.
    MESSAGE
  end

  def whatsapp_reminder_guardian
    primary_guardian_id = alumn.alumn_guardians.find(&:primary?)&.guardian_id
    guardians = alumn.guardians.to_a
    guardians.find { |guardian| guardian.id == primary_guardian_id } || guardians.min_by(&:created_at)
  end

  def effective_price
    custom_price || plan.price
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[alumn_id plan_id]
  end

  def disable
    update!(status: 1)
  end

  # `ransackable_associations` returns the names
  # of searchable associations as an array of strings.
  #
  def self.ransackable_associations(auth_object = nil)
    %w[alumn plan]
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

  private
  def set_subscribed_at_if_blank
    self.subscribed_at ||= created_at
  end
end
