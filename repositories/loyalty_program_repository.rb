class LoyaltyProgramRepository

  class LoyaltyProgram < Struct.new(:id, :name)
  end

  PROGRAMS ||= [
    LoyaltyProgram.new('BAEXECCLUB', 'British Airways Executive Club'),
    LoyaltyProgram.new('SQKRISFLYER', 'Singapore Airlines KrisFlyer'),
    LoyaltyProgram.new('AFFLYINGBLUE', 'Air France Flying Blue'),
    LoyaltyProgram.new('AMCLUBPREMIER', 'Club Premier')
  ].freeze

  class << self
    def all
      PROGRAMS
    end

    def find(id)
      PROGRAMS.detect { |program| id == program.id }
    end
  end

end
