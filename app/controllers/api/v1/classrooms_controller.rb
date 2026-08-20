  # GET /classrooms
  # Returns a list of classrooms with their associated lessons
  # GET /classrooms/:id
  # Returns a classroom with its associated lessons
  # POST /classrooms
  # Creates a new classroom
  # PATCH/PUT /classrooms/:id
  # Updates a classroom's attributes
  # DELETE /classrooms/:id
  # Deletes a classroom
class Api::V1::ClassroomsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_classroom, only: %i[ show update destroy ]

  # GET /classrooms
  def index
    @classrooms = Classroom.includes(:lessons).all
    render json: { data: @classrooms.as_json(include: :lessons) }
  end

  # GET /classrooms/1
  def show
    classroom = Classroom.includes(:lessons).find(@classroom.id)
    render json: { data: classroom.as_json(include: :lessons) }
  end

  # POST /classrooms
  def create
    @classroom = Classroom.new(classroom_params)

    if @classroom.save
      render json: @classroom, status: :created
    else
      render json: @classroom.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /classrooms/1
  def update
    if @classroom.update(classroom_params)
      render json: @classroom
    else
      render json: @classroom.errors, status: :unprocessable_entity
    end
  end

  # DELETE /classrooms/1
  def destroy
    @classroom.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_classroom
      @classroom = Classroom.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def classroom_params
      params.require(:classroom).permit(:name, :description, :is_active)
    end
end
