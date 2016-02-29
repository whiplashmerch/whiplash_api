require 'spec_helper'

describe WhiplashApi::WebHook do
  before(:all) do
    @valid_attributes = {
      url: "http://yourtesite.com",
      format: "json",
      event_name: "order.shipped"
    }
  end

  describe ".create" do
    it "creates web hook with given attributes" do
      web_hook = described_class.create @valid_attributes
      expect(web_hook).to be_persisted
      expect(described_class.all).to include(web_hook)
    end
  end

  describe ".all" do
    it "lists all the web hooks for current customer account" do
      web_hook = described_class.create @valid_attributes
      expect(described_class.all).to include(web_hook)
    end
  end

  describe ".find" do
    it "can find a web hook using its ID" do
      web_hook = described_class.create @valid_attributes
      expect(described_class.find(web_hook.id)).to eq web_hook
    end
  end

  describe ".delete" do
    it "deletes the web hook with the given ID" do
      web_hook = described_class.create @valid_attributes
      expect(described_class.all).to include(web_hook)
      described_class.delete(web_hook.id)
      expect(described_class.all).not_to include(web_hook)
    end

    it "raises error when trying to delete web hook which does not exist" do
      expect {
        described_class.delete(999999)
      }.to raise_error(WhiplashApi::Error).with_message("No Web Hook was found with given ID.")
    end
  end
end