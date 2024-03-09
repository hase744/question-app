class ChangeColumnNullOnErrorLog < ActiveRecord::Migration[6.1]
  def change
    change_column_null :error_logs, :user_id, true
  end
end
