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

ActiveRecord::Schema.define(version: 20130812174745) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "games", force: true do |t|
    t.string   "name",                  null: false
    t.integer  "size",                  null: false
    t.integer  "simulator_instance_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "games", ["simulator_instance_id", "name"], name: "index_games_on_simulator_instance_id_and_name", unique: true, using: :btree

  create_table "observation_aggs", force: true do |t|
    t.integer "observation_id",    null: false
    t.integer "symmetry_group_id", null: false
    t.float   "payoff",            null: false
    t.float   "payoff_sd"
  end

  add_index "observation_aggs", ["observation_id", "symmetry_group_id"], name: "index_observation_aggs_on_observation_id_and_symmetry_group_id", unique: true, using: :btree

  create_table "observations", force: true do |t|
    t.integer  "profile_id", null: false
    t.json     "features"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "observations", ["profile_id"], name: "index_observations_on_profile_id", using: :btree

  create_table "players", force: true do |t|
    t.float    "payoff",            null: false
    t.json     "features"
    t.integer  "observation_id",    null: false
    t.integer  "symmetry_group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["observation_id"], name: "index_players_on_observation_id", using: :btree
  add_index "players", ["symmetry_group_id"], name: "index_players_on_symmetry_group_id", using: :btree

  create_table "profiles", force: true do |t|
    t.integer  "simulator_instance_id",             null: false
    t.integer  "size",                              null: false
    t.integer  "observations_count",    default: 0, null: false
    t.text     "assignment",                        null: false
    t.hstore   "role_configuration",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["role_configuration"], name: "profiles_gin_role_configuration", using: :gin
  add_index "profiles", ["simulator_instance_id", "assignment"], name: "index_profiles_on_simulator_instance_id_and_assignment", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.integer  "count",                null: false
    t.integer  "reduced_count",        null: false
    t.string   "name",                 null: false
    t.integer  "role_owner_id",        null: false
    t.string   "role_owner_type",      null: false
    t.string   "strategies",                        array: true
    t.string   "deviating_strategies",              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["role_owner_id", "role_owner_type", "name"], name: "index_roles_on_role_owner_id_and_role_owner_type_and_name", unique: true, using: :btree

  create_table "schedulers", force: true do |t|
    t.string   "name",                                            null: false
    t.boolean  "active",                          default: false, null: false
    t.integer  "process_memory",                                  null: false
    t.integer  "time_per_observation",                            null: false
    t.integer  "observations_per_simulation",     default: 10,    null: false
    t.integer  "default_observation_requirement", default: 10,    null: false
    t.integer  "nodes",                           default: 1,     null: false
    t.integer  "size",                                            null: false
    t.integer  "simulator_instance_id",                           null: false
    t.string   "type",                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedulers", ["simulator_instance_id", "name"], name: "index_schedulers_on_simulator_instance_id_and_name", unique: true, using: :btree

  create_table "scheduling_requirements", force: true do |t|
    t.integer  "count",        null: false
    t.integer  "scheduler_id", null: false
    t.integer  "profile_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduling_requirements", ["profile_id", "scheduler_id"], name: "index_scheduling_requirements_on_profile_id_and_scheduler_id", unique: true, using: :btree
  add_index "scheduling_requirements", ["scheduler_id"], name: "index_scheduling_requirements_on_scheduler_id", using: :btree

  create_table "simulations", force: true do |t|
    t.integer  "profile_id",                        null: false
    t.integer  "scheduler_id",                      null: false
    t.integer  "size",                              null: false
    t.string   "state",         default: "pending", null: false
    t.integer  "job_id"
    t.string   "error_message"
    t.string   "qos"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simulations", ["profile_id"], name: "index_simulations_on_profile_id", using: :btree

  create_table "simulator_instances", force: true do |t|
    t.hstore   "configuration"
    t.integer  "simulator_id",       null: false
    t.string   "simulator_fullname", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simulator_instances", ["configuration"], name: "simulator_instances_gin_configuration", using: :gin
  add_index "simulator_instances", ["simulator_id"], name: "index_simulator_instances_on_simulator_id", using: :btree

  create_table "simulators", force: true do |t|
    t.string   "name",               limit: 32,                null: false
    t.string   "version",            limit: 32,                null: false
    t.string   "email",                                        null: false
    t.string   "source",                                       null: false
    t.hstore   "configuration",                                null: false
    t.text     "role_configuration",            default: "{}", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simulators", ["name", "version"], name: "index_simulators_on_name_and_version", unique: true, using: :btree

  create_table "symmetry_groups", force: true do |t|
    t.integer  "profile_id", null: false
    t.string   "role",       null: false
    t.string   "strategy",   null: false
    t.integer  "count",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "payoff"
    t.float    "payoff_sd"
  end

  add_index "symmetry_groups", ["profile_id", "role", "strategy"], name: "index_symmetry_groups_on_profile_id_and_role_and_strategy", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                default: "",    null: false
    t.string   "encrypted_password",   default: "",    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.boolean  "admin",                default: false, null: false
    t.boolean  "approved",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["admin"], name: "index_users_on_admin", using: :btree
  add_index "users", ["approved"], name: "index_users_on_approved", using: :btree
  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
