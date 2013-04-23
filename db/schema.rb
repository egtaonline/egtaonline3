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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130419211055) do

  create_table "games", :force => true do |t|
    t.string   "name",                  :null => false
    t.integer  "size",                  :null => false
    t.integer  "simulator_instance_id", :null => false
    t.text     "role_configuration"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "games_profiles", :id => false, :force => true do |t|
    t.integer "profile_id", :null => false
    t.integer "game_id",    :null => false
  end

  create_table "observations", :force => true do |t|
    t.integer  "profile_id", :null => false
    t.hstore   "features"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players", :force => true do |t|
    t.float    "payoff",            :null => false
    t.hstore   "features"
    t.integer  "observation_id",    :null => false
    t.integer  "symmetry_group_id", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "profiles", :force => true do |t|
    t.integer  "simulator_instance_id",                :null => false
    t.integer  "size",                                 :null => false
    t.integer  "observation_count",     :default => 0, :null => false
    t.string   "assignment",                           :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "schedulers", :force => true do |t|
    t.string   "name",                                               :null => false
    t.boolean  "active",                          :default => false, :null => false
    t.integer  "process_memory",                                     :null => false
    t.integer  "time_per_observation",                               :null => false
    t.integer  "observations_per_simulation",     :default => 10,    :null => false
    t.integer  "default_observation_requirement", :default => 10,    :null => false
    t.integer  "nodes",                           :default => 1,     :null => false
    t.integer  "size",                                               :null => false
    t.integer  "simulator_instance_id",                              :null => false
    t.text     "role_configuration",              :default => "{}",  :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "type",                                               :null => false
  end

  create_table "scheduling_requirements", :force => true do |t|
    t.integer  "count",        :null => false
    t.integer  "scheduler_id", :null => false
    t.integer  "profile_id",   :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "simulations", :force => true do |t|
    t.integer  "profile_id",                           :null => false
    t.integer  "scheduler_id",                         :null => false
    t.integer  "size",                                 :null => false
    t.string   "state",         :default => "pending", :null => false
    t.integer  "job_id",                               :null => false
    t.string   "error_message"
    t.string   "qos"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "simulator_instances", :force => true do |t|
    t.hstore   "configuration"
    t.integer  "simulator_id",       :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "simulator_fullname", :null => false
  end

  create_table "simulators", :force => true do |t|
    t.string   "name",               :limit => 32,                   :null => false
    t.string   "version",            :limit => 32,                   :null => false
    t.string   "email",                                              :null => false
    t.string   "source",                                             :null => false
    t.hstore   "configuration",                                      :null => false
    t.text     "role_configuration",               :default => "{}", :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  create_table "symmetry_groups", :force => true do |t|
    t.integer  "profile_id", :null => false
    t.string   "role",       :null => false
    t.string   "strategy",   :null => false
    t.integer  "count",      :null => false
    t.float    "payoff"
    t.float    "payoff_sd"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                :default => "",    :null => false
    t.string   "encrypted_password",   :default => "",    :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.boolean  "admin",                :default => false, :null => false
    t.boolean  "approved",             :default => false, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "users", ["admin"], :name => "index_users_on_admin"
  add_index "users", ["approved"], :name => "index_users_on_approved"
  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
