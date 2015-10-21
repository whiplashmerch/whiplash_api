require 'spec_helper'

describe WhiplashApi::OrderItem do

  before(:all) do
    @item  = WhiplashApi::Item.create sku: "SOME-SKU-KEY", title: "Some Title"
    @order = WhiplashApi::Order.create(
      email: "user@example.com",
      shipping_name: "Test Suite :: Name",
      shipping_address_1: "Test Suite :: Address",
      shipping_city: "Test Suite :: City",
      shipping_zip: 12345,
      shipping_country: "TZ"
    )
  end

  before(:each) do
    @oid = Digest::MD5.hexdigest SecureRandom.base64
  end

  def test_order_items
    described_class.all params: { order_id: @order.id }
  end

  describe ".create" do
    it "creates order item with given attributes" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect(order_item).to be_persisted
      expect(test_order_items).to include(order_item)
    end
    it "does not create order item without Order and Item IDs" do
      attributes = { item_id: @item.id, order_id: @order.id }
      attributes.each_pair do |field, value|
        expect {
          described_class.create attributes.merge(field => nil)
        }.to raise_error(WhiplashApi::RecordNotFound)
      end
    end
  end

  describe ".all" do
    it "lists all the items for the given Order" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect(test_order_items).to include(order_item)
    end

    it "allows filtering of listing using parameters" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect(described_class.all(params: {order_id: @order.id, since_id: order_item.id}).count).to eq 0
      described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect(described_class.all(params: {order_id: @order.id, since_id: order_item.id}).count).to eq 1
    end
  end

  describe ".find" do
    it "can find an Order Item using its ID" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect(described_class.find(order_item.id)).to eq order_item
    end
  end

  describe ".originator" do
    it "can find an Order Item using its Originator ID" do
      order_item = described_class.create(
        quantity: 1, originator_id: @oid, item_id:  @item.id, order_id: @order.id
      )
      expect(described_class.originator(@oid)).to eq order_item
    end
  end

  describe ".find_or_create_by_originator_id" do
    it "can find order item(s) with given Originator ID, if it exists" do
      order_item = described_class.create(
        quantity: 1, originator_id: @oid, item_id:  @item.id, order_id: @order.id
      )

      expect(described_class).not_to receive(:create)
      expect(described_class.find_or_create_by_originator_id(@oid)).to eq order_item
    end

    it "creates item with given attributes and a specific Originator ID, if it does not exist" do
      expect(described_class).to receive(:originator).twice.and_call_original
      expect(described_class).to receive(:create).once.and_call_original

      order_item = described_class.find_or_create_by_originator_id @oid, {
        quantity: 1, item_id:  @item.id, order_id: @order.id
      }
      expect(order_item).to be_persisted
      expect(test_order_items).to include(order_item)
      described_class.find_or_create_by_originator_id @oid
    end
  end

  describe ".update" do
    it "updates the order item with the given Order Item ID" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      described_class.update(order_item.id, quantity: 2)
      expect(order_item.reload.quantity).to eq 2
    end

    it "raises error if no order item was found with the given Order Item ID" do
      expect {
        described_class.update(999999, quantity: 2)
      }.to raise_error(WhiplashApi::RecordNotFound).with_message("No order item found with given ID.")
    end

    it "raises error when switching order item to an order which does not exist" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect {
        described_class.update(order_item.id, order_id: 999999)
      }.to raise_error(WhiplashApi::RecordNotFound)
    end
  end

  describe ".delete" do
    it "deletes the order item with the given ID" do
      order_item = described_class.create(quantity: 1, item_id:  @item.id, order_id: @order.id)
      expect(test_order_items).to include(order_item)
      described_class.delete(order_item.id)
      expect(test_order_items).not_to include(order_item)
    end
  end
end
