require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = lessons(:one)
  end

  test "should get index" do
    get api_v1_lessons_url, as: :json
    assert_response :success
  end

  test "should create lesson" do
    assert_difference("Lesson.count") do
      post api_v1_lessons_url, params: { lesson: { classroom_id: @lesson.classroom_id, plan_id: @lesson.plan_id, discipline_id: @lesson.discipline_id, schedule: @lesson.schedule, status: @lesson.status, user_id: @lesson.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show lesson" do
    get api_v1_lesson_url(@lesson), as: :json
    assert_response :success
  end

  test "should update lesson" do
    patch api_v1_lesson_url(@lesson), params: { lesson: { classroom_id: @lesson.classroom_id, plan_id: @lesson.plan_id, schedule: @lesson.schedule, status: @lesson.status, user_id: @lesson.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy lesson" do
    lesson = Lesson.create!(classroom_id: @lesson.classroom_id, plan_id: @lesson.plan_id, discipline_id: @lesson.discipline_id, schedule: @lesson.schedule, status: @lesson.status, user_id: @lesson.user_id)

    assert_difference("Lesson.count", -1) do
      delete api_v1_lesson_url(lesson), as: :json
    end

    assert_response :no_content
  end
end
