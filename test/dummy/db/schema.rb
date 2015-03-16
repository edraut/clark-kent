# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150313144015) do

  create_table "clark_kent_report_columns", force: true do |t|
    t.integer "report_id"
    t.string  "column_name"
    t.integer "column_order"
    t.string  "report_sort"
    t.string  "summary_method"
  end

  add_index "clark_kent_report_columns", ["report_id"], name: "index_clark_kent_report_columns_on_report_id"

  create_table "clark_kent_report_emails", force: true do |t|
    t.integer "report_id"
    t.string  "when_to_send"
    t.string  "name"
  end

  create_table "clark_kent_report_filters", force: true do |t|
    t.integer  "filterable_id"
    t.string   "filterable_type", default: "ClarkKent::Report"
    t.string   "string",          default: "ClarkKent::Report"
    t.string   "filter_name"
    t.string   "filter_value"
    t.string   "type"
    t.string   "duration"
    t.string   "kind_of_day"
    t.string   "offset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clark_kent_report_filters", ["filterable_id"], name: "index_clark_kent_report_filters_on_filterable_id"
  add_index "clark_kent_report_filters", ["filterable_type"], name: "index_clark_kent_report_filters_on_filterable_type"

  create_table "clark_kent_reports", force: true do |t|
    t.string   "name"
    t.string   "resource_type"
    t.string   "sharing_scope_type"
    t.integer  "sharing_scope_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clark_kent_reports", ["sharing_scope_id"], name: "index_clark_kent_reports_on_sharing_scope_id"
  add_index "clark_kent_reports", ["sharing_scope_type"], name: "index_clark_kent_reports_on_sharing_scope_type"

  create_table "clark_kent_user_report_emails", force: true do |t|
    t.integer "user_id"
    t.integer "report_email_id"
  end

  create_table "departments", force: true do |t|
    t.string "name"
  end

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.integer  "amount"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string  "name"
    t.string  "email"
    t.integer "age"
    t.integer "department_id"
  end

end
