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

ActiveRecord::Schema.define(:version => 20160402013541) do

  create_table "app_bill_dispatch_records", :force => true do |t|
    t.string   "application_id"
    t.string   "ret_type"
    t.string   "sort_flag"
    t.integer  "ret_no"
    t.string   "chk_status"
    t.date     "notice_date"
    t.text     "note"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "ret_content"
    t.integer  "bill_id"
  end

  create_table "application_cargos", :force => true do |t|
    t.integer  "application_id"
    t.integer  "no_in_contract"
    t.integer  "no"
    t.integer  "in_out_no"
    t.string   "code"
    t.string   "name"
    t.string   "specification"
    t.decimal  "quantity",       :precision => 15, :scale => 4
    t.string   "unit"
    t.decimal  "quantity1",      :precision => 15, :scale => 4
    t.string   "unit1"
    t.string   "note"
    t.string   "bak_code_ts"
    t.integer  "modify_mark"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "in_out"
  end

  create_table "applications", :force => true do |t|
    t.date     "end_date"
    t.string   "app_no"
    t.string   "seq_no"
    t.boolean  "lw_mark"
    t.boolean  "declare_type"
    t.integer  "enterprise_id"
    t.boolean  "app_class"
    t.string   "trade_code"
    t.string   "in_trade_code"
    t.string   "mast_cust"
    t.string   "dict_code"
    t.string   "in_dict_code"
    t.string   "lice_no"
    t.string   "cop_app_no"
    t.string   "contr_no"
    t.string   "agent_code"
    t.date     "d_date"
    t.integer  "convey_spa"
    t.integer  "convey_day"
    t.string   "corp"
    t.string   "decl"
    t.string   "note"
    t.integer  "in_enterprise_id"
    t.string   "in_cop_app_no"
    t.string   "in_mast_cust"
    t.string   "in_agent_code"
    t.date     "in_d_date"
    t.string   "in_corp"
    t.string   "in_decl"
    t.string   "in_note"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "pre_entry_no"
    t.integer  "contract_id"
    t.integer  "in_contract_id"
    t.string   "in_lice_no"
    t.string   "ems_no"
    t.string   "in_ems_no"
    t.boolean  "is_out_finish",    :default => false
    t.boolean  "is_finish",        :default => false
  end

  create_table "bill_cargos", :force => true do |t|
    t.boolean  "in_out"
    t.integer  "bill_id"
    t.integer  "no_in_application"
    t.integer  "no"
    t.integer  "no_in_out"
    t.integer  "cop_g_no"
    t.integer  "g_no"
    t.string   "code"
    t.string   "before_name"
    t.string   "before_specification"
    t.string   "name"
    t.string   "specification"
    t.decimal  "quantity",             :precision => 15, :scale => 4
    t.string   "unit"
    t.decimal  "quantity1",            :precision => 15, :scale => 4
    t.string   "unit1"
    t.string   "note"
    t.string   "bak_code_ts"
    t.integer  "modify_mark"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  create_table "bills", :force => true do |t|
    t.string   "pre_entry_no"
    t.string   "bill_no"
    t.string   "seq_no"
    t.integer  "enterprise_id"
    t.string   "trade_code"
    t.date     "issue_date"
    t.string   "in_trade_code"
    t.string   "cop_bill_no"
    t.string   "contr_no"
    t.string   "agent_code"
    t.string   "convey_type"
    t.string   "convey_no"
    t.string   "is_decla_em"
    t.date     "is_decla_date"
    t.string   "note"
    t.integer  "in_enterprise_id"
    t.date     "in_issue_date"
    t.string   "in_cop_bill_no"
    t.string   "in_agent_code"
    t.string   "in_is_decla_em"
    t.date     "in_is_decla_date"
    t.string   "in_note"
    t.integer  "application_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "sys_type"
    t.boolean  "is_out_finish",    :default => false
    t.boolean  "is_finish",        :default => false
  end

  create_table "cargos", :force => true do |t|
    t.integer  "enterprise_id"
    t.string   "code"
    t.string   "name"
    t.string   "specification"
    t.string   "unit"
    t.string   "unit1"
    t.string   "unit2"
    t.string   "no"
    t.string   "trade_country"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "check_methods", :force => true do |t|
    t.date     "from"
    t.date     "to"
    t.string   "method"
    t.decimal  "price",      :precision => 10, :scale => 0
    t.integer  "currency"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "checkout_enterprises", :force => true do |t|
    t.integer  "finance_id"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contract_consumptions", :force => true do |t|
    t.integer  "contract_product_id"
    t.integer  "contract_material_id"
    t.decimal  "used",                 :precision => 15, :scale => 4
    t.decimal  "wasted",               :precision => 15, :scale => 4
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  create_table "contract_materials", :force => true do |t|
    t.integer  "contract_id"
    t.string   "code"
    t.string   "name"
    t.string   "specification"
    t.string   "unit"
    t.string   "unit1"
    t.string   "unit2"
    t.decimal  "quantity",      :precision => 15, :scale => 4
    t.decimal  "unit_price",    :precision => 15, :scale => 4
    t.string   "trade_country"
    t.string   "tax_mode"
    t.string   "no"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "contract_products", :force => true do |t|
    t.integer  "contract_id"
    t.string   "code"
    t.string   "name"
    t.string   "specification"
    t.string   "unit"
    t.string   "unit1"
    t.string   "unit2"
    t.decimal  "quantity",      :precision => 15, :scale => 4
    t.decimal  "unit_price",    :precision => 15, :scale => 4
    t.string   "trade_country"
    t.string   "tax_mode"
    t.string   "no"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "contracts", :force => true do |t|
    t.integer  "enterprise_id"
    t.string   "operate_enterprise_code"
    t.string   "foreign_enterprise_code"
    t.string   "manual"
    t.string   "trade_mode"
    t.string   "tax_kind"
    t.string   "export_contract"
    t.string   "export_currency"
    t.string   "export_deal_mode"
    t.date     "export_deadline"
    t.string   "import_contract"
    t.string   "import_currency"
    t.string   "import_deal_mode"
    t.date     "import_deadline"
    t.date     "type_in_date"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "declaration_cargos", :force => true do |t|
    t.integer  "declaration_id"
    t.integer  "no_in_contract"
    t.string   "code"
    t.string   "name"
    t.string   "specification"
    t.decimal  "quantity",       :precision => 15, :scale => 4
    t.string   "unit"
    t.decimal  "quantity1",      :precision => 15, :scale => 4
    t.string   "unit1"
    t.decimal  "quantity2",      :precision => 15, :scale => 4
    t.string   "unit2"
    t.string   "trade_country"
    t.decimal  "unit_price",     :precision => 15, :scale => 4
    t.decimal  "total_price",    :precision => 15, :scale => 4
    t.string   "currency"
    t.string   "tax_mode"
    t.string   "goods_version"
    t.integer  "no"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "declaration_cargos", ["declaration_id"], :name => "declarationn_id_index"
  add_index "declaration_cargos", ["no_in_contract"], :name => "no_in_contract_index"

  create_table "declaration_containers", :force => true do |t|
    t.integer  "declaration_id"
    t.string   "code"
    t.string   "container"
    t.string   "bracket"
    t.string   "metal_cabinet"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "declaration_packings", :force => true do |t|
    t.integer  "declaration_id"
    t.string   "name"
    t.decimal  "package_amount",           :precision => 15, :scale => 4
    t.decimal  "quantity",                 :precision => 15, :scale => 4
    t.string   "unit"
    t.decimal  "gross_weight",             :precision => 15, :scale => 4
    t.decimal  "net_weight",               :precision => 15, :scale => 4
    t.decimal  "gross_weight_per_package", :precision => 15, :scale => 4
    t.decimal  "net_weight_per_package",   :precision => 15, :scale => 4
    t.integer  "no"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  create_table "declaration_transit_informations", :force => true do |t|
    t.integer  "declaration_id"
    t.string   "corporation_name"
    t.string   "corporation_code"
    t.string   "transport_tool_code"
    t.string   "transport_tool_name"
    t.string   "transport_tool_voyage_no"
    t.string   "bill_no"
    t.string   "local_transport_mode"
    t.string   "local_transport_tool_code"
    t.string   "local_transport_tool_name"
    t.string   "local_transport_tool_voyage_no"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "transit_type"
    t.string   "transit_declaration_enterprise"
  end

  create_table "declarations", :force => true do |t|
    t.integer  "enterprise_id"
    t.string   "declaration_type"
    t.string   "pre_entry_no"
    t.string   "entry_no"
    t.string   "eport_no"
    t.string   "declarant"
    t.string   "declare_enterprise_code"
    t.string   "operate_enterprise_code"
    t.string   "custom",                                                                          :null => false
    t.string   "contract_id"
    t.date     "declare_date"
    t.string   "transport_mode"
    t.string   "transport_tool"
    t.string   "truck"
    t.string   "bill_no"
    t.string   "trade_mode"
    t.string   "tax_kind"
    t.string   "trade_country"
    t.string   "port"
    t.string   "destination"
    t.string   "pay_way"
    t.string   "certification"
    t.string   "deal_mode"
    t.string   "contract_no"
    t.integer  "package_amount"
    t.string   "wrap_type"
    t.decimal  "gross_weight",                  :precision => 15, :scale => 4
    t.decimal  "net_weight",                    :precision => 15, :scale => 4
    t.string   "load_port"
    t.string   "memo"
    t.string   "attachments_mark"
    t.date     "import_export_date"
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
    t.string   "voyage_no"
    t.string   "transit_type"
    t.boolean  "is_finish"
    t.string   "created_by"
    t.string   "license"
    t.string   "warehouse_no"
    t.string   "foreign_enterprise_code"
    t.string   "usage"
    t.integer  "review_type",                                                  :default => 0
    t.boolean  "is_deleted",                                                   :default => false
    t.boolean  "is_paperless",                                                 :default => false
    t.boolean  "is_paperless_deleted",                                         :default => false
    t.string   "declaration_mode",                                             :default => "003"
    t.string   "custom_code"
    t.boolean  "is_special_relationship"
    t.boolean  "is_price_influence"
    t.boolean  "is_pay_privilege"
    t.string   "check_surety"
    t.string   "bill_type"
    t.string   "trade_area"
    t.string   "source_or_destination_country"
  end

  add_index "declarations", ["trade_mode"], :name => "trade_mode_index"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dict_attachments", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_brackets", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "manufacturer"
    t.string   "specification"
    t.decimal  "weight",        :precision => 15, :scale => 4
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "dict_bring_in_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_containers", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "valent_num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_countries", :force => true do |t|
    t.string   "code"
    t.string   "english_name"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "dict_currencies", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_customs", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_deal_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_declare_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_districts", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "kind"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_fees", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "name_en"
    t.decimal  "price",         :precision => 15, :scale => 4
    t.string   "currency_code"
    t.boolean  "is_income"
    t.boolean  "is_pay"
    t.text     "note"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "dict_goods", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "unit1"
    t.string   "unit2"
    t.string   "memo"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "specification_template", :default => "规格型号|其他"
  end

  create_table "dict_investment_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_load_ports", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "custom_code"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "dict_metal_cabinets", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.decimal  "weight",     :precision => 15, :scale => 4
    t.string   "size"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "dict_pay_ways", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_ports", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_process_types", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_receipt_statuses", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_tax_kinds", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_tax_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_trade_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_transit_declaration_types", :force => true do |t|
    t.string "code"
    t.string "name"
  end

  create_table "dict_transit_types", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_transport_modes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_trucks", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "ic_card"
    t.string   "corporation_name"
    t.string   "hk_truck_no"
    t.string   "corporation_address"
    t.string   "corporation_code"
    t.string   "corporation_telephone"
    t.string   "driver_name"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "dict_units", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_usages", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dict_wrap_types", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dispatch_records", :force => true do |t|
    t.string   "declaration_id"
    t.string   "message_id"
    t.string   "channel"
    t.string   "task_id"
    t.text     "note",           :limit => 2147483647
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "enterprise_custom_options", :force => true do |t|
    t.integer  "enterprise_id"
    t.string   "custom_code"
    t.string   "platform_id"
    t.string   "area_name"
    t.string   "user_private_key"
    t.string   "process_no"
    t.string   "ic_card_no"
    t.string   "certificate_no"
    t.decimal  "proxy_unit_price",   :precision => 15, :scale => 4
    t.decimal  "service_unit_price", :precision => 15, :scale => 4
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "trade_code"
  end

  create_table "enterprise_fees", :force => true do |t|
    t.integer  "enterprise_id"
    t.integer  "code"
    t.integer  "load_port"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "name"
    t.string   "name_en"
    t.decimal  "price",                    :precision => 15, :scale => 4
    t.string   "currency_code"
    t.boolean  "is_income"
    t.boolean  "is_pay"
    t.text     "note"
    t.string   "declaration_type"
    t.string   "checkout_enterprise_code"
  end

  create_table "enterprises", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "address"
    t.string   "linkman"
    t.string   "telephone"
    t.string   "fax"
    t.string   "bank"
    t.string   "bank_account"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "organization_code"
  end

  add_index "enterprises", ["code"], :name => "index_enterprises_on_code", :unique => true

  create_table "finance_fees", :force => true do |t|
    t.integer  "finance_id"
    t.integer  "code"
    t.integer  "load_port"
    t.string   "name"
    t.string   "name_en"
    t.decimal  "price",                  :precision => 15, :scale => 4
    t.string   "currency_code"
    t.boolean  "is_income"
    t.boolean  "is_pay"
    t.text     "note"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "checkout_enterprise_id"
  end

  create_table "finances", :force => true do |t|
    t.integer  "declaration_id"
    t.boolean  "is_made"
    t.integer  "review"
    t.integer  "maker"
    t.integer  "reviewer"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "combine_no"
    t.boolean  "is_paid",        :default => false
  end

  create_table "foreign_enterprises", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "address"
    t.string   "linkman"
    t.string   "telephone"
    t.string   "fax"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "foreign_enterprises", ["code"], :name => "index_foreign_enterprises_on_code", :unique => true

  create_table "manage_relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "enterprise_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "peer"
    t.string   "subject"
    t.string   "body"
    t.boolean  "sent"
    t.boolean  "read"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "options", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.text     "mark"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "salt"
    t.string   "encrypted_password"
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "roles_mask"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
