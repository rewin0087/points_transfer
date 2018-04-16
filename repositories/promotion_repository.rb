class PromotionRepository

  # Attributes
  #   - type: percentage, amount
  #   - fulfillment_type: immediate, end_of_promotion
  #   - start: Date, starting time of promo
  #   - end: Date, ending date of promo
  class Promotion < Struct.new(:loyalty_program_id, :type, :start, :end, :fulfillment_type, :tiers)
    def applicable_tier(amount)
      tiers
        .sort_by(&:threshold)
        .reverse
        .detect { |promo_tier| amount >= promo_tier.threshold }
    end

    def calculated_amount(amount)
      calculated_amount = if (tier = applicable_tier(amount))
        tier_amount_from_percentage_type(tier, amount) || tier.amount
      end

      calculated_amount || 0
    end

    def percentage?
      type == 'percentage'
    end

    def tier_amount_from_percentage_type(tier, amount)
      (tier.amount / 100.0 * amount).round if tier && percentage?
    end
  end

  class PromotionTier < Struct.new(:threshold, :amount)
  end

  PROMOTIONS ||= [
    Promotion.new(
      'BAEXECCLUB',
      'percentage',
      Date.today,
      Date.today + 10,
      'immediate',
      [
        PromotionTier.new(10_000, 5),
        PromotionTier.new(30_000, 15)
      ]
    ),
    Promotion.new(
      'SQKRISFLYER',
      'amount',
      Date.today,
      Date.today + 2,
      'immediate',
      [
        PromotionTier.new(0, 1_000),
        PromotionTier.new(5_000, 2_000)
      ]
    ),
    Promotion.new(
      'AMCLUBPREMIER',
      'percentage',
      Date.today,
      Date.today + 3,
      'end_of_promotion',
      [
        PromotionTier.new(10_000, 100)
      ]
    ),
    Promotion.new(
      'AFFLYINGBLUE',
      'percentage',
      Date.today - 10,
      Date.today - 3,
      'end_of_promotion',
      [
        PromotionTier.new(0, 50)
      ]
    )
  ]

  class << self
    def all
      PROMOTIONS
    end

    def find_for_loyalty_program(loyalty_program_id)
      PROMOTIONS.select { |promotion| promotion.loyalty_program_id == loyalty_program_id }
    end
  end

end
