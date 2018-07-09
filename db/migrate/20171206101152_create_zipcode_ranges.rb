class CreateZipcodeRanges < SolidusSupport::Migration[4.2]
  def change
    create_table :spree_zipcode_ranges do |t|
      t.integer :zone_id, null: false
      t.integer :start, null: false
      t.integer :end, null: false
    end
  end
end
