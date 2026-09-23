class Api::V1::ProductsController < ApplicationController
  include Pagy::Method
  before_action :authenticate_request!
  before_action :set_product, only: %i[ show update destroy ]

  # GET /api/v1/products
  def index
    @q = Product.active.ransack(params[:q])
    pagy, records = pagy(:offset, @q.result(distinct: true))
    render json: {
      data: records,
      links: pagy.urls_hash,
      pages: pagy.data_hash(data_keys: [ :series ])[:series].map { |item| item == :gap ? item : item.to_i },
      total: pagy.count
    }
  end

  # GET /api/v1/products/1
  def show
    render json: @product
  end

  # POST /api/v1/products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/products/1
  def destroy
    @product.is_active = false
    if @product.save
      render json: { successful: true }, status: :ok
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :price, :description)
    end
end
