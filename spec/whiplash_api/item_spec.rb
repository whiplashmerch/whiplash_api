require 'spec_helper'

describe WhiplashApi::Item do
  describe ".create" do
    it "creates item with given attributes" do
      item = described_class.create sku: @sku, title: "Some Product Title"
      expect(item).to be_persisted
      expect(described_class.all).to include(item)
    end

    xit "does not create item without a title" do
      item = described_class.create sku: @sku, title: nil
      expect(item).not_to be_persisted
      expect(described_class.all).not_to include(item)
    end
  end

  describe ".all" do
    it "lists all the items for current customer account" do
      item = described_class.create sku: @sku, title: "AAA"
      expect(described_class.all).to include(item)
    end

    it "allows filtering of listing using parameters" do
      item = described_class.create sku: @sku, title: "BBB"
      expect(described_class.all(params: {since_id: item.id}).count).to eq 0
      described_class.create sku: @sku, title: "CCC"
      expect(described_class.all(params: {since_id: item.id}).count).to eq 1
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
      item = described_class.create sku: @sku, title: "AAA"
      expect(described_class).not_to receive(:create)
      expect(described_class.find_or_create_by_sku(@sku, title: "AAA")).to eq item
    end

    it "creates item with given attributes and a specific SKU, if it does not exist" do
      expect(described_class).to receive(:first_by_sku).with(@sku).twice.and_call_original
      expect(described_class).to receive(:create).once.and_call_original

      item = described_class.find_or_create_by_sku @sku, title: "AAA"
      expect(item).to be_persisted
      expect(described_class.sku(@sku)).to include(item)
      described_class.find_or_create_by_sku @sku, title: "AAA"
    end
  end

  # NOTE: In my testing, I wasn't able to find any item with an originator_id
  # specified (inside testing environment). Further, when an item is saved by
  # specifying the `originator_id`, `originator_id` is not returned in
  # subsequent requests. Probably, the API service is not returning
  # `originator_id` for the items.
  describe ".originator" do
    xit "can find an Item using its Originator ID" do
      item = described_class.create sku: @sku, title: "EEE", originator_id: "ZZZ123"
      expect(described_class.originator("ZZZ123")).to eq item
    end
  end
  describe ".find_or_create_by_originator_id" do
    xit "can find item(s) with given Originator ID, if it exists"
    xit "creates item with given attributes and a specific Originator ID, if it does not exist"
  end

  describe ".update" do
    it "updates the item with the given SKU" do
      item = described_class.create sku: @sku, title: "AAA"
      described_class.update(sku: @sku, title: "BBB")
      expect(item.reload.title).to eq "AAA"
    end

    it "raises error if no items are found with the given SKU" do
      expect {
        described_class.update(sku: @sku, title: "BBB")
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
      items = [described_class.first_by_sku(@sku)].flatten

      expect(items.count).to eq 1
      expect(items.first.title).to eq "BBB"
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
