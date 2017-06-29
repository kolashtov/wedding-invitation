class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :name
      t.string :inviteid

      t.timestamps null: false
    end
  end
end
