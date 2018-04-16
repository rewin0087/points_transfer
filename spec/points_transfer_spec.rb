require_relative '../points_transfer'

describe PointsTransfer do

  let(:loyalty_program_id) { 'BAEXECCLUB' }
  let(:amount) { 1_000 }
  let(:params) { {
    id: loyalty_program_id,
    amount: amount,
    member_id: 'XXX'
  } }

  subject { PointsTransfer.new(params) }

  after { TransactionRepository.clear }

  shared_examples_for 'Records single base transaction' do
    it 'creates relevant transactions' do
      result = subject.call

      expect(result.success?).to eq true

      transactions = result.outcome
      expect(transactions.count).to eq 1

      base_transaction = transactions.first
      expect(base_transaction.loyalty_program_id).to eq loyalty_program_id
      expect(base_transaction.member_id).to eq 'XXX'
      expect(base_transaction.amount).to eq amount
      expect(base_transaction.type).to eq 'base'
      expect(base_transaction.parent_transaction_id).to eq nil
    end
  end

  shared_examples_for 'Records base and promotion transactions' do
    it 'records base and bonus transaction' do
      result = subject.call

      expect(result.success?).to eq true

      transactions = result.outcome
      expect(transactions.count).to eq 2

      base_transaction = transactions.first
      expect(base_transaction.loyalty_program_id).to eq loyalty_program_id
      expect(base_transaction.member_id).to eq 'XXX'
      expect(base_transaction.amount).to eq amount
      expect(base_transaction.type).to eq 'base'
      expect(base_transaction.parent_transaction_id).to eq nil

      promotion_transaction = transactions.last
      expect(promotion_transaction.loyalty_program_id).to eq loyalty_program_id
      expect(promotion_transaction.member_id).to eq 'XXX'
      expect(promotion_transaction.amount).to eq recorded_promotion_points_amount
      expect(promotion_transaction.type).to eq 'promotion'
      expect(promotion_transaction.parent_transaction_id).to eq base_transaction.id
    end
  end

  it_behaves_like 'Records single base transaction'

  context 'No such loyalty program' do
    let(:loyalty_program_id) { 'FAKEPROGRAM' }

    it 'rejects transaction for invalid program ID' do
      result = subject.call

      expect(result.success?).to eq false
      expect(result.outcome).to eq ['Loyalty program not found']
    end
  end

  context 'Percentage-based promotion' do
    let(:amount) { 9_999 }

    it_behaves_like 'Records single base transaction'

    context '10k transfer threshold met' do
      let(:amount) { 10_000 }

      let(:recorded_promotion_points_amount) { 500 }

      it_behaves_like 'Records base and promotion transactions'
    
      context '29.999k transaction' do
        let(:amount) { 29_999 }

        let(:recorded_promotion_points_amount) { 1_500 }

        it_behaves_like 'Records base and promotion transactions'
      end
    end

    context '30k transfer threshold met' do
      let(:amount) { 30_000 }

      let(:recorded_promotion_points_amount) { 4_500 }

      it_behaves_like 'Records base and promotion transactions'
    end
  end

  context 'Amount-based promotion' do
    let(:loyalty_program_id) { 'SQKRISFLYER' }
    let(:recorded_promotion_points_amount) { 1_000 }

    it_behaves_like 'Records base and promotion transactions'

    context '4.999k transfer' do
      let(:amount) { 4_999 }

      it_behaves_like 'Records base and promotion transactions'
    end

    context '5k transfer threshold reached' do
      let(:amount) { 5_000 }
      let(:recorded_promotion_points_amount) { 2_000 }

      it_behaves_like 'Records base and promotion transactions'
    end
  end

  context 'Promotion not immediately fulfilled' do
    let(:loyalty_program_id) { 'AMCLUBPREMIER' }
    let(:amount) { 10_000 }

    it_behaves_like 'Records single base transaction'
  end

  context 'Promotion expired' do
    let(:loyalty_program_id) { 'AFFLYINGBLUE' }
    let(:amount) { 3_000 }

    it_behaves_like 'Records single base transaction'
  end

end
