# GET /lessons
# Returns a list of lessons with their associated plan, user, and classroom
# GET /lessons/:id
# Returns a lesson with its associated plan, user, and classroom
# POST /lessons
# Creates a new lesson
# PATCH/PUT /lessons/:id
# Updates a lesson's attributes
# DELETE /lessons/:id
# Deletes a lesson
class Api::V1::LessonsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_lesson, only: %i[ show update destroy ]

  # GET /lessons
  def index
    @lessons = Lesson.includes(:plan, :user, :classroom).all
    render json: { data: @lessons.as_json(include: [ :plan, :user, :classroom ]) }
  end

  # GET /lessons/1
  def show
    lesson = Lesson.includes(:plan, :user, :classroom).find(@lesson.id)
    render json: { data: lesson.as_json(include: [ :plan, :user, :classroom ]) }
  end

  # POST /lessons
  def create
    @lesson = Lesson.new(lesson_params)

    if @lesson.save
      render json: @lesson, status: :created
    else
      render json: @lesson.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lessons/1
  def update
    if @lesson.update(lesson_params)
      render json: @lesson
    else
      render json: @lesson.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lessons/1
  def destroy
    @lesson.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def lesson_params
      params.require(:lesson).permit(:plan_id, :user_id, :classroom_id, :discipline_id, :schedule, :status)
    end
end
