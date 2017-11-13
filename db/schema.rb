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

ActiveRecord::Schema.define(version: 20171110152558) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "uniq_id"
    t.text     "description"
    t.string   "matchers",                 array: true
    t.index ["matchers"], name: "index_categories_on_matchers", using: :gin
  end

  create_table "characteristics", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "license"
    t.integer  "organization_id"
    t.string   "visibility"
    t.string   "state"
    t.string   "source"
    t.string   "version"
    t.integer  "author_id"
    t.integer  "maintainer_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "categories",        default: [],              array: true
    t.integer  "characteristic_id"
    t.index ["author_id"], name: "index_datasets_on_author_id", using: :btree
    t.index ["characteristic_id"], name: "index_datasets_on_characteristic_id", using: :btree
    t.index ["maintainer_id"], name: "index_datasets_on_maintainer_id", using: :btree
    t.index ["organization_id"], name: "index_datasets_on_organization_id", using: :btree
  end

  create_table "distributions", force: :cascade do |t|
    t.integer  "dataset_id"
    t.string   "uri"
    t.string   "name"
    t.text     "description"
    t.string   "format"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "artifact"
    t.index ["dataset_id"], name: "index_distributions_on_dataset_id", using: :btree
  end

  create_table "licenses", force: :cascade do |t|
    t.boolean  "domain_content"
    t.boolean  "domain_data"
    t.boolean  "domain_software"
    t.string   "family"
    t.string   "identifier"
    t.string   "maintainer"
    t.string   "od_conformance"
    t.string   "osd_conformance"
    t.string   "status"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "email"
    t.string   "url"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "username",                               null: false
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

end
