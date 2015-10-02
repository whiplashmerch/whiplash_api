require 'spec_helper'

describe WhiplashApi::Order do
  let!(:valid_attributes) {{
    email: "user@example.com",
    shipping_name: "Test Suite :: Name",
    shipping_address_1: "Test Suite :: Address",
    shipping_city: "Test Suite :: City",
    shipping_zip: 12345,
    shipping_country: "TZ"
  }}

  before(:each) do
    @oid = Digest::MD5.hexdigest(Time.now.to_s)
  end

  describe ".create" do
    it "creates order with given attributes" do
      order = described_class.create valid_attributes
      expect(order).to be_persisted
      expect(described_class.all).to include(order)
    end

    xit "does not create order without required fields" do
      valid_attributes.each_pair do |field, value|
        order = described_class.create valid_attributes.merge(field => nil)
        expect(order).not_to be_persisted
        expect(described_class.all).not_to include(order)
      end
    end
  end

  describe ".all" do
    it "lists all the orders for current customer account" do
      order = described_class.create valid_attributes
      expect(described_class.all).to include(order)
    end

    it "allows filtering of listing using parameters" do
      order = described_class.create valid_attributes
      expect(described_class.all(params: {shipping_country: "TZ"})).to include order
      expect(described_class.all(params: {shipping_country: "US"})).not_to include order
    end
  end

  describe ".find" do
    it "can find an Order using its ID" do
      order = described_class.create valid_attributes
      expect(described_class.find(order.id)).to eq order
    end
  end

  describe ".originator" do
    it "can find an Order using its Originator ID" do
      order = described_class.create valid_attributes.merge(originator_id: @oid)
      expect(described_class.originator(@oid)).to eq order
    end
  end

  describe ".find_or_create_by_originator_id" do
    it "can find item(s) with given Originator ID, if it exists" do
      attributes = valid_attributes.merge(originator_id: @oid)
      order = described_class.create attributes

      expect(described_class).not_to receive(:create)
      expect(described_class.find_or_create_by_originator_id(@oid, valid_attributes)).to eq order
    end

    it "creates item with given attributes and a specific Originator ID, if it does not exist" do
      expect(described_class).to receive(:originator).twice.and_call_original
      expect(described_class).to receive(:create).once.and_call_original

      order = described_class.find_or_create_by_originator_id @oid, valid_attributes
      expect(order).to be_persisted
      expect(described_class.all).to include(order)
      described_class.find_or_create_by_originator_id @oid, valid_attributes
    end
  end

  describe ".update" do
    it "updates the item with the given Originator ID" do
      order = described_class.find_or_create_by_originator_id @oid, valid_attributes
      described_class.update(originator_id: @oid, shipping_name: "AAA")
      expect(order.reload.shipping_name).to eq "AAA"
    end

    it "raises error if no items are found with the given Originator ID" do
      expect {
        described_class.update(originator_id: @oid, shipping_name: "AAA")
      }.to raise_error(WhiplashApi::RecordNotFound).with_message("No order found with given Originator ID.")
    end

    it "raises error when updating order which has already been shipped" do
      order = described_class.create originator_id: @oid, shipping_name: "AAA"
      allow_any_instance_of(described_class).to receive(:status).and_return(300)
      expect {
        described_class.update(originator_id: @oid, shipping_name: "BBB")
      }.to raise_error(WhiplashApi::Error).with_message("Orders may only be updated before they have been shipped.")
    end
  end

  it "allows pausing, resuming, cancelling or uncancelling of orders" do
    order = described_class.create originator_id: @oid, shipping_name: "AAA"
    expect(order).to be_processing

    message = "Cannot release an order that has not been paused."
    expect{order.release}.to raise_error(WhiplashApi::Error).with_message(message)

    order.pause
    expect(order.reload).to be_paused

    order.release
    expect(order.reload).to be_processing

    # simulate shipping
    allow_any_instance_of(described_class).to receive(:status).and_return 300
    message = "Orders may only be paused before they have been shipped."
    expect{order.pause}.to raise_error(WhiplashApi::Error).with_message(message)

    message = "Orders may only be cancelled before they have been shipped."
    expect{order.cancel}.to raise_error(WhiplashApi::Error).with_message(message)

    # back to actual status of the order
    allow_any_instance_of(described_class).to receive(:status).and_call_original

    message = "Cannot uncancel an order that has not been cancelled."
    expect{order.uncancel}.to raise_error(WhiplashApi::Error).with_message(message)

    order.cancel
    expect(order.reload).to be_cancelled

    order.uncancel
    expect(order.reload).to be_processing
  end
end
