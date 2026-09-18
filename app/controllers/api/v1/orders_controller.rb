class Api::V1::OrdersController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_order, only: %i[ show update destroy ]

  # GET /orders
  def index
    scope = filtered_orders_scope
    return if performed?

    pagy, records = pagy(:offset, scope.order(created_at: :desc))
    render json: {
      data: records.map { |order| serialize_order(order) },
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i },
      total: pagy.count
    }
  end

  # GET /orders/1
  def show
    render json: serialize_order(@order, detailed: true)
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    @order.user_email = @current_user_email

    ActiveRecord::Base.transaction do
      order_lines = resolve_order_lines!
      @order.total = order_lines.sum { |line| line[:product].price * line[:quantity] }
      @order.save!
      create_order_lines!(order_lines)
      register_advance_payment!
    end

    render json: @order, status: :created
  rescue ActionController::ParameterMissing => e
    render json: { errors: { products: [ e.message ] } }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.to_hash(true) }, status: :unprocessable_entity
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy!
  end

  private
    def filtered_orders_scope
      scope = Order.includes(:alumn)

      if params[:status].present?
        unless Order.statuses.key?(params[:status])
          render json: { errors: { status: [ "must be pending, partial, or paid" ] } }, status: :unprocessable_entity
          return scope.none
        end

        scope = scope.where(status: params[:status])
      end

      if params[:alumn_id].present?
        alumn_id = Integer(params[:alumn_id], exception: false)
        unless alumn_id
          render json: { errors: { alumn_id: [ "must be an integer" ] } }, status: :unprocessable_entity
          return scope.none
        end

        scope = scope.where(alumn_id: alumn_id)
      end

      scope
    end

    def serialize_order(order, detailed: false)
      payload = order.as_json(
        methods: :remaining_balance,
        include: {
          alumn: { only: %i[id name last_name email] }
        }
      )
      payload["total"] = order.total.to_f
      payload["paid_amount"] = order.paid_amount.to_f
      payload["remaining_balance"] = order.remaining_balance.to_f

      return payload unless detailed

      payload["order_products"] = order.order_products.includes(:product).map do |order_product|
        line = order_product.as_json(
          only: %i[id product_id quantity price],
          include: {
            product: { only: %i[id name description is_active] }
          }
        )
        line["price"] = order_product.price.to_f
        line
      end
      payload["payments"] = order.payments.order(paid_at: :asc, created_at: :asc).map do |payment|
        item = payment.as_json(only: %i[id quantity paid_at created_at user_email payment_method])
        item["quantity"] = payment.quantity.to_f
        item
      end
      payload
    end

    def resolve_order_lines!
      items = order_products_params.map do |item|
        product_id = Integer(item[:id], exception: false)
        quantity = Integer(item[:quantity], exception: false)

        invalidate_order!(:products, "contains an invalid product id") unless product_id
        invalidate_order!(:products, "quantity must be a positive integer") unless quantity&.positive?

        { product_id: product_id, quantity: quantity }
      end

      product_ids = items.pluck(:product_id)
      invalidate_order!(:products, "contains duplicate products") unless product_ids.uniq.size == product_ids.size

      products_by_id = Product.where(id: product_ids).index_by(&:id)
      missing_ids = product_ids.uniq - products_by_id.keys
      invalidate_order!(:products, "contains unknown product ids: #{missing_ids.join(', ')}") if missing_ids.any?

      items.map do |item|
        item.merge(product: products_by_id.fetch(item[:product_id]))
      end
    end

    def create_order_lines!(order_lines)
      order_lines.each do |line|
        @order.order_products.create!(
          product: line[:product],
          quantity: line[:quantity],
          price: line[:product].price
        )
      end
    end

    def register_advance_payment!
      amount = advance_amount
      return if amount.zero?

      invalidate_order!(:paid_amount, "must be greater than or equal to zero") if amount.negative?

      payment = Payment.create!(
        alumn_id: @order.alumn_id,
        quantity: amount,
        payment_method: :cash,
        user_email: @current_user_email
      )
      @order.register_payment!(payment)
    end

    def advance_amount
      raw_amount = params.dig(:order, :paid_amount)
      return 0.to_d if raw_amount.blank?

      amount = BigDecimal(raw_amount.to_s, exception: false)
      invalidate_order!(:paid_amount, "is not a valid amount") unless amount
      amount
    end

    def invalidate_order!(attribute, message)
      @order.errors.add(attribute, message)
      raise ActiveRecord::RecordInvalid, @order
    end

    def order_products_params
      products = params.require(:products)
      raise ActionController::ParameterMissing, :products unless products.is_a?(Array) && products.any?

      products.map { |product| product.permit(:id, :quantity) }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:alumn_id, :description)
    end
end
