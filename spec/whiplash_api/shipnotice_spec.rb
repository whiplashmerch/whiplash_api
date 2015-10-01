require 'spec_helper'

describe WhiplashApi::Shipnotice do
  before(:all) do
    @item = WhiplashApi::Item.create sku: "SOME-SKU-KEY"
    @valid_attributes = {
      sender: "Some Name",
      eta: "2016-01-01 03:00",
      warehouse_id: 1
    }
  end

  describe ".create" do
    it "creates shipment notice with given attributes" do
      notice = described_class.create @valid_attributes
      expect(notice).to be_persisted
      expect(described_class.all).to include(notice)
    end

    xit "does not create order without required fields" do
      @valid_attributes.each_pair do |field, value|
        notice = described_class.create @valid_attributes.merge(field => nil)
        expect(notice).not_to be_persisted
        expect(described_class.all).not_to include(notice)
      end
    end
  end

  describe ".all" do
    it "lists all the shipment notices for current customer account" do
      notice = described_class.create @valid_attributes
      expect(described_class.all).to include(notice)
    end

    it "allows filtering of listing using parameters" do
      notice = described_class.create @valid_attributes
      expect(described_class.all(params: {since_id: notice.id}).count).to eq 0
      described_class.create @valid_attributes
      expect(described_class.all(params: {since_id: notice.id}).count).to eq 1
    end
  end

  describe ".find" do
    it "can find a Shipment Notice using its ID" do
      notice = described_class.create @valid_attributes
      expect(described_class.find(notice.id)).to eq notice
    end
  end

  describe ".update" do
    it "updates the Shipment notice with the given ID" do
      notice = described_class.create @valid_attributes
      described_class.update(notice.id, warehouse_id: 2)
      expect(notice.reload.warehouse_id).to eq 2
    end

    it "raises error if no shipment notice was found with the given ID" do
      expect {
        described_class.update(999999, warehouse_id: 2)
      }.to raise_error(WhiplashApi::Error).with_message("No Shipment notice found with given ID.")
    end

    it "raises error when updating shipment notice which has already been received" do
      notice = described_class.create @valid_attributes
      allow_any_instance_of(described_class).to receive(:status).and_return(150)
      expect {
        described_class.update(notice.id, warehouse_id: 2)
      }.to raise_error(WhiplashApi::Error).with_message("Shipment notices may only be updated before they have been received.")
    end
  end

  describe ".delete" do
    it "deletes the shipment notice with the given ID" do
      notice = described_class.create @valid_attributes
      expect(described_class.all).to include(notice)
      described_class.delete(notice.id)
      expect(described_class.all).not_to include(notice)
    end

    it "raises error when trying to delete shipment notice which does not exist" do
      expect {
        described_class.delete(999999)
      }.to raise_error(WhiplashApi::Error).with_message("No Shipment notice found with given ID.")
    end

    it "raises error when trying to delete a shipment notice which has already been received" do
      notice = described_class.create @valid_attributes
      allow_any_instance_of(described_class).to receive(:status).and_return(150)
      expect {
        described_class.delete(notice.id)
      }.to raise_error(WhiplashApi::Error).with_message("Shipment notices may only be deleted before they have been received.")
    end
  end
end
