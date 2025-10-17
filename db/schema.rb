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

ActiveRecord::Schema[8.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "_prisma_migrations", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "checksum", limit: 64, null: false
    t.timestamptz "finished_at"
    t.string "migration_name", limit: 255, null: false
    t.text "logs"
    t.timestamptz "rolled_back_at"
    t.timestamptz "started_at", default: -> { "now()" }, null: false
    t.integer "applied_steps_count", default: 0, null: false
  end

  create_table "account", primary_key: "member_id", id: { type: :string, limit: 10 }, force: :cascade do |t|
    t.string "business_type", limit: 50
    t.string "customer_type", limit: 50, null: false
    t.boolean "is_overdue", null: false
    t.boolean "is_cheque_returned", null: false
    t.boolean "billing_note_used", null: false
    t.uuid "account_credit_id", null: false
    t.string "cv_status", limit: 20, null: false
    t.boolean "is_guarantee_expired", null: false
    t.boolean "is_over_limit", null: false
    t.string "order_status", limit: 20, null: false
    t.string "billing_channel_email", limit: 255
    t.boolean "billing_channel_is_messenger_used"
    t.string "billing_channel_line_id", limit: 50
    t.integer "billing_note_attachments_copy_number", null: false
    t.string "billing_note_recipient_location_type", limit: 50
    t.string "class_price_condition", limit: 20
    t.string "class_price_price_tier", limit: 255, null: false
    t.string "credit_controller_employee_id", limit: 36, null: false
    t.string "credit_controller_full_name", limit: 255, null: false
    t.string "account_receivable_type", limit: 20
    t.boolean "is_credit_check_required", null: false
    t.boolean "is_multiple_members_allowed_in_single_billing_note", null: false
    t.boolean "is_payment_receipt_always_issued_with_billing_note", null: false
    t.string "member_name", limit: 255, null: false
    t.string "payment_location_type", limit: 50, null: false
    t.string "sales_executive_area_zone", limit: 255, null: false
    t.string "sales_executive_employee_id", limit: 36, null: false
    t.string "sales_executive_full_name", limit: 255, null: false
    t.string "tax_branch", limit: 20, null: false
    t.string "tax_id", limit: 20, null: false
    t.string "vat_type", limit: 20, null: false
    t.string "sub_business_type_code", limit: 255, null: false
    t.string "sub_business_type_name", limit: 255
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.string "payment_location_bank", limit: 255
    t.string "payment_location_branch", limit: 255
  end

  create_table "account_address", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "type", limit: 50, null: false
    t.string "address_1", limit: 255, null: false
    t.string "address_2", limit: 255
    t.string "sub_district", limit: 255, null: false
    t.string "district", limit: 255, null: false
    t.string "province", limit: 255, null: false
    t.string "postal_code", limit: 5, null: false
    t.string "latitude", limit: 20
    t.string "longitude", limit: 20
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "account_billing_note_attachment", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "document_code", limit: 20, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["member_id", "document_code"], name: "account_billing_note_attachment_member_id_document_code_key", unique: true
  end

  create_table "account_contact", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "type", limit: 50, null: false
    t.string "department", limit: 255
    t.string "line_id", limit: 50
    t.string "phone_no", limit: 20
    t.string "email", limit: 255
    t.string "address_text", limit: 255
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.string "first_name", limit: 50
    t.boolean "is_approved"
    t.boolean "is_displayed_on_invoice"
    t.string "last_name", limit: 50
    t.string "prefix", limit: 10
  end

  create_table "account_credit", id: :uuid, default: nil, force: :cascade do |t|
    t.decimal "pure_credit_limit", precision: 20, scale: 6, null: false
    t.decimal "temporary_credit_limit", precision: 20, scale: 6
    t.timestamptz "temporary_credit_start_date"
    t.timestamptz "temporary_credit_expiry_date"
    t.decimal "reserved_credit", precision: 20, scale: 6, null: false
    t.decimal "outstanding_balance", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, null: false
    t.timestamptz "pure_credit_start_date"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "account_guarantee", id: :uuid, default: nil, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "type", limit: 50, null: false
    t.decimal "amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, null: false
    t.timestamptz "start_date", null: false
    t.timestamptz "expiry_date"
    t.string "invoice_no", limit: 36
    t.timestamptz "invoice_date"
    t.string "back_code", limit: 50
    t.boolean "is_document_returned", default: false, null: false
    t.timestamptz "document_return_date"
    t.timestamptz "deleted_date"
    t.string "bank_guarantee_no", limit: 50
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "account_store", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "store_code", limit: 20, null: false
    t.string "store_name", limit: 255, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["member_id", "store_code", "store_name"], name: "account_store_member_id_store_code_store_name_key", unique: true
  end

  create_table "account_term", primary_key: "member_id", id: { type: :string, limit: 10 }, force: :cascade do |t|
    t.integer "credit_term_print", null: false
    t.integer "credit_term_real", null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "advance_receipt", primary_key: "advance_receipt_no", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "receipt_no", limit: 36, null: false
    t.string "currency", limit: 3, null: false
    t.timestamptz "attached_date"
    t.timestamptz "canceled_date"
    t.decimal "advance_receipt_amount", precision: 20, scale: 6, null: false
    t.timestamptz "advance_receipt_date", null: false
    t.string "remark", limit: 255
    t.string "channel", limit: 50, null: false
    t.decimal "remaining_amount", precision: 20, scale: 6, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["receipt_no"], name: "advance_receipt_receipt_no_key", unique: true
  end

  create_table "billing_condition", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.text "schedule_type", null: false
    t.integer "day_of_month"
    t.text "day_of_week"
    t.text "week_of_month"
    t.integer "start_day"
    t.integer "end_day"
    t.boolean "is_active", null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "billing_note", primary_key: "billing_note_no", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.timestamptz "due_date", null: false
    t.string "status", limit: 20, null: false
    t.timestamptz "billing_note_date", null: false
    t.string "currency", limit: 3, null: false
    t.string "member_id", limit: 10, null: false
    t.string "remark", limit: 255
    t.decimal "grand_total_amount", precision: 20, scale: 6, null: false
    t.timestamptz "printed_date"
    t.timestamptz "canceled_date"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "billing_note_item", id: :uuid, default: nil, force: :cascade do |t|
    t.string "billing_note_no", limit: 36, null: false
    t.string "document_type", limit: 50, null: false
    t.string "document_no", limit: 36, null: false
    t.string "status", limit: 20, null: false
    t.timestamptz "canceled_date"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["billing_note_no", "document_no"], name: "billing_note_item_billing_note_no_document_no_key", unique: true
  end

  create_table "cheque_payment", id: :uuid, default: nil, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "cheque_no", limit: 36, null: false
    t.string "cheque_status", limit: 50, null: false
    t.decimal "amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, null: false
    t.string "issue_bank", limit: 100, null: false
    t.string "issue_bank_branch", limit: 100, null: false
    t.timestamptz "issue_date", null: false
    t.string "deposit_bank", limit: 100, null: false
    t.boolean "is_bangkok", null: false
    t.boolean "is_pay_in", null: false
    t.timestamptz "canceled_date"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "credit_check_rule", id: :text, force: :cascade do |t|
    t.string "customer_type", limit: 20, null: false
    t.boolean "is_overdue", null: false
    t.boolean "is_bg_expire", null: false
    t.boolean "is_over_limit", null: false
    t.boolean "is_cheque_returned", null: false
    t.string "order_status", limit: 20, null: false
    t.string "cv_status", limit: 20, null: false
    t.string "order_eligibility", limit: 100, null: false
    t.string "new_order_status", limit: 20, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["cv_status", "is_cheque_returned", "is_over_limit", "is_bg_expire", "is_overdue", "customer_type", "order_status"], name: "credit_check_rule_cv_status_is_cheque_returned_is_over_limi_key", unique: true
  end

  create_table "credit_note", primary_key: "credit_note_no", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "invoice_no", limit: 36, null: false
    t.timestamptz "credit_note_date", null: false
    t.decimal "credit_note_amount", precision: 20, scale: 6, null: false
    t.string "original_credit_note_no", limit: 36
    t.string "replaced_credit_note_no", limit: 36
    t.string "currency", limit: 3, null: false
    t.string "remark", limit: 255
    t.timestamptz "attached_date"
    t.decimal "remaining_amount", precision: 20, scale: 6, null: false
    t.string "store_id", limit: 3, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["original_credit_note_no"], name: "credit_note_original_credit_note_no_key", unique: true
    t.index ["replaced_credit_note_no"], name: "credit_note_replaced_credit_note_no_key", unique: true
  end

  create_table "document_seq_no", id: :text, force: :cascade do |t|
    t.string "branch_code", limit: 3, null: false
    t.string "doc_type", limit: 50, null: false
    t.integer "month", null: false
    t.integer "seq_no", null: false
    t.integer "year", null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["branch_code", "doc_type", "year", "month"], name: "document_seq_no_branch_code_doc_type_year_month_key", unique: true
  end

  create_table "invoice", primary_key: "invoice_no", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "order_no", limit: 36, null: false
    t.timestamptz "invoice_date", null: false
    t.decimal "invoice_amount", precision: 20, scale: 6, null: false
    t.decimal "remaining_amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, null: false
    t.timestamptz "due_date", null: false
    t.string "status", limit: 20, null: false
    t.text "original_invoice_no"
    t.text "replaced_invoice_no"
    t.string "seller_user_id", limit: 50, null: false
    t.string "collector_user_id", limit: 50, null: false
    t.string "remark", limit: 255
    t.string "store_id", limit: 3, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["original_invoice_no"], name: "invoice_original_invoice_no_key", unique: true
    t.index ["replaced_invoice_no"], name: "invoice_replaced_invoice_no_key", unique: true
  end

  create_table "job", id: :uuid, default: nil, force: :cascade do |t|
    t.string "job_name", limit: 50, null: false
    t.timestamptz "last_started_at"
    t.timestamptz "last_finished_at"
    t.integer "max_retry", null: false
    t.integer "current_retry", null: false
    t.integer "retry_backoff", null: false
    t.text "job_data"
    t.text "job_result"
    t.string "job_group_id", limit: 50
    t.string "status", limit: 20, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "matching_log", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "event_type", limit: 50, null: false
    t.uuid "event_id", null: false
    t.string "operation_type", limit: 50, null: false
    t.string "doc_ref_type", limit: 20, null: false
    t.string "doc_ref_no", limit: 36, null: false
    t.decimal "doc_ref_old_amount", precision: 20, scale: 6, null: false
    t.decimal "doc_ref_new_amount", precision: 20, scale: 6, null: false
    t.decimal "matching_amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, default: "THB", null: false
    t.uuid "event_group_id", null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "order", primary_key: "order_no", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.timestamptz "order_date", null: false
    t.decimal "order_amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, null: false
    t.string "order_status", limit: 50, null: false
    t.string "store_id", limit: 3, null: false
    t.string "axtra_omni_order_id", limit: 50, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "payment_condition", id: :text, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.text "schedule_type", null: false
    t.integer "day_of_month"
    t.text "day_of_week"
    t.text "week_of_month"
    t.boolean "is_active", null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.integer "end_day"
    t.integer "start_day"
  end

  create_table "payment_receipt", primary_key: "receipt_no", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "member_id", limit: 10, null: false
    t.string "channel", limit: 50, null: false
    t.string "created_by_user_id", limit: 50
    t.string "created_by_user_name", limit: 50
    t.timestamptz "printed_date"
    t.timestamptz "canceled_date"
    t.string "overpayment_action", limit: 50
    t.decimal "overpayment_amount", precision: 20, scale: 6, default: "0.0", null: false
    t.string "store_id", limit: 3, null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.string "doc_issue_unit", limit: 50, null: false
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "payment_receipt_billing_item", primary_key: ["receipt_no", "document_no"], force: :cascade do |t|
    t.string "receipt_no", limit: 36, null: false
    t.string "document_no", limit: 36, null: false
    t.string "document_type", limit: 50, null: false
    t.decimal "remaining_amount", precision: 20, scale: 6, null: false
    t.decimal "payment_amount", precision: 20, scale: 6
    t.string "currency", limit: 3, null: false
    t.string "billing_note_no", limit: 36
    t.timestamptz "canceled_date"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "payment_receipt_payment_item", id: :uuid, default: nil, force: :cascade do |t|
    t.string "receipt_no", limit: 36, null: false
    t.string "payment_source_id", limit: 100
    t.string "payment_type", limit: 50, null: false
    t.decimal "payment_amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, null: false
    t.timestamptz "canceled_date"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "payment_record", id: :uuid, default: nil, force: :cascade do |t|
    t.string "payment_hub_reference", limit: 64
    t.string "credit_sale_reference", limit: 64, null: false
    t.decimal "amount", precision: 20, scale: 6, null: false
    t.string "payment_type", limit: 50, null: false
    t.string "status", limit: 20, null: false
    t.string "source_type", limit: 50, null: false
    t.string "source_id", limit: 50, null: false
    t.text "qr_code"
    t.text "bar_code"
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
    t.string "reference_1", limit: 64, null: false
    t.string "reference_2", limit: 64, null: false
    t.index ["payment_hub_reference", "credit_sale_reference"], name: "payment_record_payment_hub_reference_credit_sale_reference_key", unique: true
  end

  create_table "transaction_log", id: :text, force: :cascade do |t|
    t.uuid "account_credit_id", null: false
    t.string "member_id", limit: 10, null: false
    t.text "event_id", null: false
    t.string "event_type", limit: 50, null: false
    t.string "operation_type", limit: 50, null: false
    t.decimal "old_amount", precision: 20, scale: 6, null: false
    t.decimal "new_amount", precision: 20, scale: 6, null: false
    t.string "doc_ref_type", limit: 20, null: false
    t.string "doc_ref_no", limit: 36, null: false
    t.decimal "doc_ref_amount", precision: 20, scale: 6, null: false
    t.string "currency", limit: 3, default: "THB", null: false
    t.timestamptz "created_date", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  add_foreign_key "account", "account_credit", name: "account_account_credit_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "account_address", "account", column: "member_id", primary_key: "member_id", name: "account_address_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "account_billing_note_attachment", "account", column: "member_id", primary_key: "member_id", name: "account_billing_note_attachment_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "account_contact", "account", column: "member_id", primary_key: "member_id", name: "account_contact_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "account_guarantee", "account", column: "member_id", primary_key: "member_id", name: "account_guarantee_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "account_store", "account", column: "member_id", primary_key: "member_id", name: "account_store_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "account_term", "account", column: "member_id", primary_key: "member_id", name: "account_term_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "advance_receipt", "account", column: "member_id", primary_key: "member_id", name: "advance_receipt_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "advance_receipt", "payment_receipt", column: "receipt_no", primary_key: "receipt_no", name: "advance_receipt_receipt_no_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "billing_condition", "account", column: "member_id", primary_key: "member_id", name: "billing_condition_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "billing_note", "account", column: "member_id", primary_key: "member_id", name: "billing_note_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "billing_note_item", "billing_note", column: "billing_note_no", primary_key: "billing_note_no", name: "billing_note_item_billing_note_no_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "cheque_payment", "account", column: "member_id", primary_key: "member_id", name: "cheque_payment_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "credit_note", "account", column: "member_id", primary_key: "member_id", name: "credit_note_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "credit_note", "credit_note", column: "original_credit_note_no", primary_key: "credit_note_no", name: "credit_note_original_credit_note_no_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "credit_note", "credit_note", column: "replaced_credit_note_no", primary_key: "credit_note_no", name: "credit_note_replaced_credit_note_no_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "credit_note", "invoice", column: "invoice_no", primary_key: "invoice_no", name: "credit_note_invoice_no_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "invoice", "account", column: "member_id", primary_key: "member_id", name: "invoice_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "invoice", "invoice", column: "original_invoice_no", primary_key: "invoice_no", name: "invoice_original_invoice_no_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "invoice", "invoice", column: "replaced_invoice_no", primary_key: "invoice_no", name: "invoice_replaced_invoice_no_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "matching_log", "account", column: "member_id", primary_key: "member_id", name: "matching_log_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "order", "account", column: "member_id", primary_key: "member_id", name: "order_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "payment_condition", "account", column: "member_id", primary_key: "member_id", name: "payment_condition_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "payment_receipt", "account", column: "member_id", primary_key: "member_id", name: "payment_receipt_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "payment_receipt_billing_item", "payment_receipt", column: "receipt_no", primary_key: "receipt_no", name: "payment_receipt_billing_item_receipt_no_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "payment_receipt_payment_item", "payment_receipt", column: "receipt_no", primary_key: "receipt_no", name: "payment_receipt_payment_item_receipt_no_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "transaction_log", "account", column: "member_id", primary_key: "member_id", name: "transaction_log_member_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "transaction_log", "account_credit", name: "transaction_log_account_credit_id_fkey", on_update: :cascade, on_delete: :restrict
end
