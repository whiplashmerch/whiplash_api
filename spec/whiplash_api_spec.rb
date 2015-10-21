require 'spec_helper'

describe WhiplashApi do

  def doubled(min, max)
    (min..max).map{|val| [val, val*2]}.flatten.sort
  end

  it 'has a version number' do
    expect(WhiplashApi::VERSION).not_to be nil
  end

  # NOTE: This is a crud (not really reliable) test, but it works for our use
  # case. We can search for a better way to test this, but to be honest, testing
  # threads is a major pain.
  #
  context "when run in threads" do

    def in_parallel(range, klass)
      collected = []
      range.map do |val|
        Thread.new do
          range.max.times do |i|
            WhiplashApi::Base.api_key = (val*i).to_s
            collected.push klass.headers['X-API-KEY']
          end
        end
      end.each(&:join)
      collected.sort
    end

    it "does not mix api key for different classes together" do
      range    = (1..10)
      expected = range.map do |val|
        range.max.times.map{|i| (val*i).to_s }
      end.flatten.sort

      WhiplashApi.constants.select do |klass|
        WhiplashApi.const_get(klass).respond_to?(:headers)
      end.each do |klass|
        actual = in_parallel(range, WhiplashApi.const_get(klass))
        expect(actual).to eq(expected), "Thread execution was mixed up for class: WhiplashApi::#{klass}"
      end
    end
  end
end
