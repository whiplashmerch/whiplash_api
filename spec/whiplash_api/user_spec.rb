require 'spec_helper'

describe WhiplashApi::User do

  describe ".create" do
    it "is unsupported" do
      expect {
        described_class.create email: 'test@test.com'
      }.to raise_error(WhiplashApi::Error)
    end
  end

  describe ".all" do
    it "is unsupported" do
      expect {
        described_class.all
      }.to raise_error(WhiplashApi::Error)
    end
  end

  describe ".me" do
    it "get our own user" do
      user = described_class.me
      expect(user.id).to eq 1
    end
  end

  describe ".update" do
    it "is currently unsupported" do
      user = described_class.me
      expect {
        user.update_attributes(first_name: "Larry")
      }.to raise_error(WhiplashApi::Error)
    end
  end

  describe ".delete" do
    it "is unsupported" do
      user = described_class.me
      expect {
        user.delete(user.id)
      }.to raise_error(WhiplashApi::Error)
    end
  end

end
