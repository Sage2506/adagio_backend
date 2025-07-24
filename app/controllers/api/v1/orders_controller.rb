class Api::V1::OrdersController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_request!
  before_action :set_order, only: %i[ show update destroy ]

  # GET /orders
  def index
    pagy, records = pagy(Order.all)
    render json: { data: records, links: pagy_jsonapi_links(pagy), pages: pagy.series.map { |item| item == :gap ? item : item.to_i } }
  end

  # GET /orders/1
  def show
    render json: @order
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    @order.user_email = @current_user_email
    if params[:paid_amount].present?
      if params[:paid_amount] == params[:total]
        @order.status = 2
      else
        @order.status = 1
      end
    else
        @order.status = 0
    end
    ActiveRecord::Base.transaction do
    if @order.save
      if params[:products].present?
        unless link_products_to_order
          raise ActiveRecord::RecordInvalid.new(@order)
        end
      end
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def link_products_to_order
    params[:products].each do |product|
      orderProduct = OrderProduct.new(
        order_id: @order.id,
        product_id: product[:id],
        quantity: product[:quantity],
        price: product[:price],
        )
      unless orderProduct.save
        @order.errors.add(:base, "Unknown error product: #{product.id}")
        false
      end
    end
    true
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
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:alumn_id, :total, :description, :paid_amount)
    end
end
