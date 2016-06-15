require 'spec_helper'

describe WhiplashApi::Customer do
  before(:all) do
    @customer_id = 1
  end

  describe ".count" do
    it "counts the number of customers in the user's account" do
      expect(described_class.count).to eq(2)
    end
  end

  describe ".create" do
    it "is currently unsupported" do
      expect {
        described_class.create name: "Test Customer", billing_email: 'test@test.com'
      }.to raise_error(WhiplashApi::Error)
    end
  end

  describe ".all" do
    it "lists all the customers for the current user" do
      expect(described_class.all.collect(&:id)).to include(@customer_id)
    end
  end

  describe ".find" do
    it "can find a customer using its ID" do
      expect(described_class.find(@customer_id).id).to eq @customer_id
    end
  end

  describe ".update" do
    it "is currently unsupported" do
      expect {
        described_class.find(@customer_id).update_attributes(name: "Test Customer")
      }.to raise_error(WhiplashApi::Error)
    end
  end

  describe ".delete" do
    it "is currently unsupported" do
      expect {
        described_class.delete(@customer_id)
      }.to raise_error(WhiplashApi::Error)
    end
  end

end
