class AddTemplatesExportedToShops < ActiveRecord::Migration
  def self.up
    add_column :shops, :templates_exported, :boolean, :default => false
  end

  def self.down
    remove_column :shops, :templates_exported
  end
end
