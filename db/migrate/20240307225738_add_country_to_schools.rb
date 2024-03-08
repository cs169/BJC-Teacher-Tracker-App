class AddCountryToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :country, :string
  end
end
