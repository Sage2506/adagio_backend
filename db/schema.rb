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

ActiveRecord::Schema[8.1].define(version: 2026_08_19_234315) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alumn_guardians", force: :cascade do |t|
    t.bigint "alumn_id", null: false
    t.datetime "created_at", null: false
    t.bigint "guardian_id", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_alumn_guardians_on_alumn_id"
    t.index ["guardian_id"], name: "index_alumn_guardians_on_guardian_id"
  end

  create_table "alumns", force: :cascade do |t|
    t.text "address"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "is_active"
    t.boolean "is_guardian_required_for_leaving", default: false, null: false
    t.string "last_name"
    t.string "name"
    t.string "phone_number"
    t.text "special_med_conditions", default: "None", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assistances", force: :cascade do |t|
    t.bigint "alumn_id", null: false
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_assistances_on_alumn_id"
    t.index ["lesson_id"], name: "index_assistances_on_lesson_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.boolean "is_active"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "disciplines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "guardians", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "is_active"
    t.string "last_name"
    t.string "name"
    t.string "phone_number"
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.bigint "discipline_id", null: false
    t.bigint "plan_id", null: false
    t.datetime "schedule"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["classroom_id"], name: "index_lessons_on_classroom_id"
    t.index ["discipline_id"], name: "index_lessons_on_discipline_id"
    t.index ["plan_id"], name: "index_lessons_on_plan_id"
    t.index ["user_id"], name: "index_lessons_on_user_id"
  end

  create_table "order_payments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "payment_id"], name: "index_order_payments_on_order_and_payment", unique: true
    t.index ["order_id"], name: "index_order_payments_on_order_id"
    t.index ["payment_id"], name: "index_order_payments_on_payment_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "index_order_products_on_order_and_product", unique: true
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
    t.check_constraint "price > 0::numeric", name: "order_products_price_positive"
    t.check_constraint "quantity > 0", name: "order_products_quantity_positive"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "alumn_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "paid_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.string "user_email"
    t.index ["alumn_id"], name: "index_orders_on_alumn_id"
    t.check_constraint "paid_amount <= total", name: "orders_paid_amount_not_above_total"
    t.check_constraint "paid_amount >= 0::numeric", name: "orders_paid_amount_non_negative"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "orders_status_valid"
  end

  add_check_constraint "orders", "total > 0::numeric", name: "orders_total_positive", validate: false

  create_table "payments", force: :cascade do |t|
    t.bigint "alumn_id", null: false
    t.datetime "created_at", null: false
    t.datetime "paid_at"
    t.integer "payment_method", default: 0, null: false
    t.decimal "quantity", precision: 12, scale: 2, null: false
    t.string "reference"
    t.datetime "updated_at", null: false
    t.string "user_email"
    t.index ["alumn_id"], name: "index_payments_on_alumn_id"
    t.index ["payment_method", "paid_at"], name: "index_payments_on_payment_method_and_paid_at"
    t.index ["reference"], name: "index_payments_on_reference", unique: true, where: "(reference IS NOT NULL)"
    t.check_constraint "quantity > 0::numeric", name: "payments_quantity_positive"
  end

  create_table "plan_disciplines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "discipline_id", null: false
    t.bigint "plan_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discipline_id"], name: "index_plan_disciplines_on_discipline_id"
    t.index ["plan_id"], name: "index_plan_disciplines_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active"
    t.string "name"
    t.float "price"
    t.float "registration_cost"
    t.integer "subscription_duration"
    t.integer "tolerance_days"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.boolean "is_active", default: true, null: false
    t.string "name"
    t.decimal "price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.check_constraint "price > 0::numeric", name: "products_price_positive"
  end

  create_table "subscription_payments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "payment_id", null: false
    t.bigint "subscription_id", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_subscription_payments_on_payment_id"
    t.index ["subscription_id"], name: "index_subscription_payments_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "alumn_id", null: false
    t.datetime "created_at", null: false
    t.float "custom_price"
    t.date "due_date"
    t.date "last_payment_date"
    t.float "paid_amount", default: 0.0
    t.bigint "plan_id", null: false
    t.integer "status"
    t.datetime "subscribed_at"
    t.datetime "updated_at", null: false
    t.index ["alumn_id"], name: "index_subscriptions_on_alumn_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
  end

  create_table "user_disciplines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "discipline_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["discipline_id"], name: "index_user_disciplines_on_discipline_id"
    t.index ["user_id"], name: "index_user_disciplines_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_active", default: true, null: false
    t.string "last_name", null: false
    t.string "name", null: false
    t.string "password_digest"
    t.string "phone_number"
    t.integer "role", default: 0, null: false
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
  add_foreign_key "order_payments", "orders"
  add_foreign_key "order_payments", "payments"
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "products"
  add_foreign_key "orders", "alumns"
  add_foreign_key "payments", "alumns"
  add_foreign_key "plan_disciplines", "disciplines"
  add_foreign_key "plan_disciplines", "plans"
  add_foreign_key "subscription_payments", "payments"
  add_foreign_key "subscription_payments", "subscriptions"
  add_foreign_key "subscriptions", "alumns"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "user_disciplines", "disciplines"
  add_foreign_key "user_disciplines", "users"
end
