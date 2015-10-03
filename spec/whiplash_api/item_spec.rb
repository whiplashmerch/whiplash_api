require 'spec_helper'

describe WhiplashApi::Item do
  before :each do
    @sku = "SOME-SKU-KEY"
  end

  describe ".count" do
    it "counts the number of items (with filtering) in the customer's account" do
      expect(described_class.count).to be_a(Integer)
      expect(described_class.count(created_at_min: 4.hours.since)).to eq 0
    end
  end

  describe ".create" do
    it "creates item with given attributes" do
      count = described_class.count
      item  = described_class.create sku: @sku, title: "Some Product Title"
      expect(item).to be_persisted
      expect(described_class.count).to eq(count + 1)
    end

    xit "does not create item without a title" do
      count = described_class.count
      expect{
        described_class.create sku: @sku, title: nil
      }.to raise_error(WhiplashApi::Error)
    end
  end

  describe ".all" do
    it "lists all the items for current customer account" do
      item = described_class.create sku: @sku, title: "AAA"
      expect(described_class.all).to include(item)
    end

    it "allows filtering of listing using parameters" do
      item = described_class.create sku: @sku, title: "BBB"
      expect(described_class.count(since_id: item.id)).to eq 0
      described_class.create sku: @sku, title: "CCC"
      expect(described_class.count(since_id: item.id)).to eq 1
    end
  end

  describe ".find" do
    it "can find an Item using its ID" do
      item = described_class.create sku: @sku, title: "DDD"
      expect(described_class.find(item.id)).to eq item
    end
  end

  describe ".find_or_create" do
    it "can find item with a given ID, if it exists" do
      item = described_class.create sku: @sku, title: "AAA"
      expect(described_class).not_to receive(:create)
      expect(described_class.find_or_create(item.id)).to eq item
    end

    it "creates item with given attributes, if it does not exist" do
      expect(described_class).to receive(:find).thrice.and_call_original
      expect(described_class).to receive(:create).once.and_call_original
      expect{ described_class.find(99999) }.to raise_error(WhiplashApi::RecordNotFound)

      item = described_class.find_or_create 99999, sku: @sku, title: "AAA"
      expect(item).to be_persisted
      described_class.find_or_create item.id, sku: @sku, title: "AAA"
    end
  end

  describe ".find_or_create_by_sku" do
    it "can find item(s) with given SKU, if it exists" do
      @sku = "SOME-SKU-KEY-2"
      item  = described_class.create sku: @sku, title: "AAA"
      expect(described_class).not_to receive(:create)
      found = described_class.find_or_create_by_sku(@sku, title: "AAA")
      expect(found.id).to eq item.id
    end

    it "creates item with given attributes and a specific SKU, if it does not exist" do
      @sku = "SOME-SKU-KEY-3"
      expect(described_class).to receive(:first_by_sku).with(@sku).twice.and_call_original
      expect(described_class).to receive(:create).once.and_call_original

      item = described_class.find_or_create_by_sku @sku, title: "AAA"
      expect(item).to be_persisted
      expect(described_class.sku(@sku)).to include(item)
      described_class.find_or_create_by_sku @sku, title: "AAA"
    end
  end

  describe ".originator" do
    it "can find an Item using its Originator ID" do
      item = described_class.create sku: @sku, title: "EEE", originator_id: "ZZZ123"
      expect(described_class.originator("ZZZ123")).to eq item
    end
  end
  describe ".find_or_create_by_originator_id" do
    it "can find item(s) with given Originator ID, if it exists" do
      item = described_class.create sku: @sku, originator_id: "ZZZ1234", title: "EEE"
      expect(described_class).not_to receive(:create)
      expect(described_class.find_or_create_by_originator_id("ZZZ1234", sku: @sku)).to eq item
    end
    it "creates item with given attributes and a specific Originator ID, if it does not exist" do
      @oid = "RAND123412"
      expect(described_class).to receive(:originator).with(@oid).twice.and_call_original
      expect(described_class).to receive(:create).once.and_call_original

      item = described_class.find_or_create_by_originator_id @oid, sku: @sku, title: "AAA"
      expect(item).to be_persisted
      expect(described_class.sku(@sku)).to include(item)
      described_class.find_or_create_by_originator_id @oid, sku: @sku, title: "AAA"
    end
  end

  describe ".update" do
    it "updates the item with the given SKU" do
      @sku = "SOME-SKU-KEY-4"
      item = described_class.create sku: @sku, title: "AAA"
      described_class.update(sku: @sku, title: "BBB")
      expect(item.reload.title).to eq "AAA"
    end

    it "raises error if no items are found with the given SKU" do
      expect {
        described_class.update(sku: "SOME-SKU-KEY-THAT-DOES-NOT-EXIST", title: "BBB")
      }.to raise_error(WhiplashApi::Error).with_message("No item was found with given SKU.")
    end

    it "raises error if multiple items are found with the given SKU" do
      described_class.create sku: @sku, title: "AAA"
      described_class.create sku: @sku, title: "BBB"
      expect {
        described_class.update(sku: @sku, title: "BBB")
      }.to raise_error(WhiplashApi::Error).with_message("Multiple items were found with given SKU.")
    end
  end

  describe ".first_by_sku" do
    it "finds the latest item with the given SKU" do
      described_class.create sku: @sku, title: "AAA"
      described_class.create sku: @sku, title: "BBB"
      item = described_class.first_by_sku(@sku)
      expect(item).to be_a(described_class)
    end
  end

  describe ".delete" do
    it "deletes/deactivates the item with the given ID" do
      item = described_class.create sku: @sku, title: "AAA"
      expect(described_class.all).to include(item)
      described_class.delete(item.id)
      expect(described_class.all).not_to include(item)
    end
  end

  describe "#update_attributes" do
    it "updates the current item with given attributes" do
      item = described_class.create sku: @sku, title: "AAA"
      item.update_attributes(title: "BBB")
      expect(item.reload.title).to eq "BBB"
    end
  end

  describe "#destroy" do
    it "deletes/deactivates the current item" do
      item = described_class.create sku: @sku, title: "AAA"
      item.destroy
      expect(described_class.all).not_to include(item)
    end
  end
end
