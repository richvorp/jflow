require 'spec_helper'

describe JFlow::Activity::Map do

  let(:map) { JFlow::Activity::Map.new() }

  describe "#add_activity" do
    it "should allow to add an activity" do
      map.add_activity("foo", "1.0", String, {})
      expect(map.klass_for("foo", "1.0")).to eq String
    end
  end

  describe "#klass_for" do
    it "should return nil if cannot find a mapping" do
      map.add_activity("foo", "1.0", String, {})
      expect(map.klass_for("bar", "1.0")).to eq nil
      expect(map.klass_for("foo", "1")).to eq nil
    end
  end

end