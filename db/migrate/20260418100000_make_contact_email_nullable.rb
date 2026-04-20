class MakeContactEmailNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :contacts, :email, true
  end
end
