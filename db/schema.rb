# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_02_202448) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alumn_guardians", force: :cascade do |t|
    t.bigint "alumn_id", null: false
    t.bigint "guardian_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_alumn_guardians_on_alumn_id"
    t.index ["guardian_id"], name: "index_alumn_guardians_on_guardian_id"
  end

  create_table "alumns", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.text "address"
    t.string "phone_number"
    t.string "email"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "birth_date"
    t.text "special_med_conditions", default: "None", null: false
  end

  create_table "assistances", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "alumn_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_assistances_on_alumn_id"
    t.index ["lesson_id"], name: "index_assistances_on_lesson_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disciplines", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guardians", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.text "address"
    t.string "phone_number"
    t.string "email"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "user_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "schedule"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "discipline_id", null: false
    t.index ["classroom_id"], name: "index_lessons_on_classroom_id"
    t.index ["discipline_id"], name: "index_lessons_on_discipline_id"
    t.index ["plan_id"], name: "index_lessons_on_plan_id"
    t.index ["user_id"], name: "index_lessons_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "alumn_id", null: false
    t.bigint "payment_id"
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.integer "status"
    t.float "total"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_orders_on_alumn_id"
    t.index ["payment_id"], name: "index_orders_on_payment_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "alumn_id", null: false
    t.float "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_payments_on_alumn_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "plan_disciplines", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "discipline_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discipline_id"], name: "index_plan_disciplines_on_discipline_id"
    t.index ["plan_id"], name: "index_plan_disciplines_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.float "price"
    t.integer "subscription_duration"
    t.integer "tolerance_days"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.float "price"
    t.string "description"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscription_payments", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_subscription_payments_on_payment_id"
    t.index ["subscription_id"], name: "index_subscription_payments_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "alumn_id", null: false
    t.date "due_date"
    t.integer "status"
    t.date "last_payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_subscriptions_on_alumn_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
  end

  create_table "user_disciplines", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "discipline_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discipline_id"], name: "index_user_disciplines_on_discipline_id"
    t.index ["user_id"], name: "index_user_disciplines_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.string "email", null: false
    t.text "address"
    t.integer "role", default: 0, null: false
    t.string "password_digest"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "alumn_guardians", "alumns"
  add_foreign_key "alumn_guardians", "guardians"
  add_foreign_key "assistances", "alumns"
  add_foreign_key "assistances", "lessons"
  add_foreign_key "lessons", "classrooms"
  add_foreign_key "lessons", "disciplines"
  add_foreign_key "lessons", "plans"
  add_foreign_key "lessons", "users"
  add_foreign_key "orders", "alumns"
  add_foreign_key "orders", "payments"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "alumns"
  add_foreign_key "payments", "users"
  add_foreign_key "plan_disciplines", "disciplines"
  add_foreign_key "plan_disciplines", "plans"
  add_foreign_key "subscription_payments", "payments"
  add_foreign_key "subscription_payments", "subscriptions"
  add_foreign_key "subscriptions", "alumns"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "user_disciplines", "disciplines"
  add_foreign_key "user_disciplines", "users"
end
