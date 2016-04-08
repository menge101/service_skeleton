Sequel.migration do
  up do
    create_table(:bones) do
      primary_key :id
      String :name, null: false
    end
  end

  down do
    drop_table(:bones)
  end
end
