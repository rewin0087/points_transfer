class TransactionRepository

  # Attributes
  #   - type: base, promotion
  class Transaction < Struct.new(:id, :loyalty_program_id, :member_id,
    :amount, :type, :parent_transaction_id)
  end

  class << self

    def transactions
      @@transactions ||= []
    end

    def all
      transactions
    end

    def create(loyalty_program_id:, member_id:, amount:, type:, parent_transaction_id: nil)
      new_transaction = Transaction.new(
        transactions.count + 1,
        loyalty_program_id,
        member_id,
        amount,
        type,
        parent_transaction_id
      )

      transactions << new_transaction

      new_transaction
    end

    def find(id)
      transactions.detect { |transaction| transaction.id == id }
    end

    def clear
      transactions.clear
    end
  end

end
