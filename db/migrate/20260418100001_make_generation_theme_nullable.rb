class MakeGenerationThemeNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :generations, :theme, true
  end
end
