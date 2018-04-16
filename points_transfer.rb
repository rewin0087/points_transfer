require 'simple_operation'
require 'date'

require_relative 'repositories/loyalty_program_repository'
require_relative 'repositories/promotion_repository'
require_relative 'repositories/transaction_repository'

# SimpleOperation is a public gem framing a Service Operation
# Outputs a result and validity of the outcome
#  - outcome: content of the outcome, either:
#    - the outcome of data
#    - An array of error messages
#  - success?: validity of the outcome

# Logic of Service
# 1. Sample of checks that the incoming params are correct
# 2. Check for applicable promotion
# 3. Compute promotion transaction if applicable
#    - Ignore if thresholds not met
#    - Apply only if fulfillment is immediate
class PointsTransfer < SimpleOperation.new(:params)

  result :success?, 
    :outcome, 
    :promotion_transaction,
    :errors,
    :program,
    :transaction,
    :promotions

  def initialize(params)
    @errors = []
    @program = LoyaltyProgramRepository.find(params[:id])
    @promotions = PromotionRepository.find_for_loyalty_program(params[:id])
    super(params)
  end

  def call
    unless @program
      @errors << 'Loyalty program not found'
      return result false, @errors unless @errors.empty?
    end

    validate_and_create_transaction_and_promotion!
    result true, [@transaction, @promotion_transaction].compact
  end

  private

    def validate_and_create_transaction_and_promotion!
      return if @promotions.empty?
      create_transaction!
      create_transaction_promotion!
    end

    def create_transaction_promotion!
      if immediate_promotion? && promotion_amount.positive?
        @promotion_transaction = TransactionRepository.create(
          loyalty_program_id: @program.id,
          member_id: params[:member_id],
          amount: promotion_amount,
          type: 'promotion',
          parent_transaction_id: @transaction.id
        )
      end
    end

    def promotion_amount
      @promotion_amount ||= applicable_promotion.calculated_amount(params[:amount])
    end

    def immediate_promotion?
      applicable_promotion && applicable_promotion.fulfillment_type == 'immediate'
    end

    def applicable_promotion
      @applicable_promotion ||= @promotions.detect do |promotion|
        Date.today >= promotion.start && Date.today < promotion.end
      end
    end

    def create_transaction!
      @transaction = TransactionRepository.create(
        loyalty_program_id: @program.id,
        member_id: params[:member_id],
        amount: params[:amount],
        type: 'base'
      )
    end
end
