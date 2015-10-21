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
    @oid = Digest::MD5.hexdigest SecureRandom.base64
  end

  describe ".count" do
    it "counts the number of orders (with filtering) in the customer's account" do
      expect(described_class.count).to be_a(Integer)
      expect(described_class.count(created_at_min: 4.hours.since)).to eq 0
    end
  end

  describe ".create" do
    it "creates order with given attributes" do
      count = described_class.count
      item  = WhiplashApi::Item.create sku: "SOME-SKU-KEY", title: "Some Title"
      attrs = valid_attributes.merge(order_items: [{item_id: item.id, quantity: 1}])
      order = described_class.create attrs

      expect(order).to be_persisted
      expect(order.order_items.map(&:item_id)).to include item.id
      expect(described_class.count).to eq(count + 1)
    end

    # xit "does not create order without required fields" do
    #   count = described_class.count
    #   valid_attributes.each_pair do |field, value|
    #     expect {
    #       described_class.create valid_attributes.merge(field => nil)
    #     }.to raise_error(WhiplashApi::Error)
    #   end
    # end
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
  end

  it "allows pausing, resuming, cancelling or uncancelling of orders at class level" do
    order = described_class.create originator_id: @oid, shipping_name: "AAA"
    expect(order).to be_processing

    described_class.pause(order.id)
    expect(order.reload).to be_paused

    described_class.release(order.id)
    expect(order.reload).to be_processing

    described_class.cancel(order.id)
    expect(order.reload).to be_cancelled

    described_class.uncancel(order.id)
    expect(order.reload).to be_processing

    order.cancel # test instance level status modifications
    expect(order.reload).to be_cancelled
  end
end
