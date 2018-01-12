require 'oystercard'

CARD_LIMIT = 90

describe Oystercard do
  subject(:card) { described_class.new }
  let(:entry_station) { double :station }
  let(:exit_station) { double :station }
  let(:journey) { double :journey }
  let(:journey) { {entry_station: entry_station, exit_station: exit_station} }

  describe 'Balance' do
    it "has a balance of 0" do
      expect(card.balance).to eq 0
    end
  end

  describe 'journey history' do
    it "has an empty journey history at start" do
      expect(card.journey_history).to be_empty
    end
  end

  describe '#top_up' do
    it "tops up the oystercard" do
      expect(card.top_up(10)).to eq 10
    end

    it "to raise an error if top up amount is greater than 90" do
      expect {card.top_up(100)}.to raise_error "There is a limit of #{CARD_LIMIT}"
    end
  end

  describe '#touch_in' do
    context 'sufficient balance' do
      it 'alters balance on double touch in' do
        card.top_up(30)
        card.touch_in(entry_station)
        expect {card.touch_in(entry_station)}.to change {card.balance}
      end

      it 'has started journey' do
        card.top_up(30)
        card.touch_in(entry_station)
        expect(card.current_journey).not_to be nil
      end
    end

    context 'insufficient balance' do
      it 'if balance is below the minimum fare, card wont touch in' do
        expect {card.touch_in(entry_station)}.to raise_error "you dont have enough money"
      end
    end

  end

  describe '#touch_out' do
    context 'sufficient balance' do
      it 'is expected to deduct fare when touching out' do
        card.top_up(30)
        card.touch_in(entry_station)
        expect { card.touch_out(exit_station) }.to change { card.balance }.by (-Oystercard::MINIMUM_FARE)
      end
    end

  end
end
