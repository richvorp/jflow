require 'spec_helper'

class FooActivity
  include JFlow::Activity::Mixin
end

describe JFlow::Activity::Mixin do
  it "should add a class method called activity" do
    expect(FooActivity.respond_to?(:activity)).to eq true
  end

  describe ".activity" do
    it "should create a ActivityDefinition properly" do
      expect(JFlow::Activity::Definition).to receive(:new)
                                         .with(FooActivity, {:baz=>:qux, :name=>"foo.bar"})
      FooActivity.activity('foo.bar') do
        {baz: :qux}
      end
    end
  end
end