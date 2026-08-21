class AddPaymentMethodAndReferenceToPayments < ActiveRecord::Migration[8.1]
  def change
    # 1. Agregar payment_method como integer con default 0 (cash)
    add_column :payments, :payment_method, :integer, null: false, default: 0

    # 2. Agregar reference como string para guardar IDs de transacciones externas
    add_column :payments, :reference, :string

    # 3. Agregar índice para búsquedas rápidas por referencia
    add_index :payments, :reference, unique: true, where: "reference IS NOT NULL"

    # 4. Agregar índice compuesto para consultas comunes
    add_index :payments, [ :payment_method, :paid_at ]
  end
end
