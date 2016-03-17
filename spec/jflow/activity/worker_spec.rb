require 'spec_helper'

describe JFlow::Activity::Worker do

  let(:worker){ JFlow::Activity::Worker.new("domain", "tasklist")}
  let(:task){double(:task)}

  describe "#process" do
    it "should call run!" do
      expect(task).to receive(:run!)
      worker.process(task)
    end
    it "should call failed on exceptions" do
      error = RuntimeError.new("foo")
      expect(task).to receive(:run!).and_raise error
      expect(task).to receive(:failed!).with error
      worker.process(task)
    end
  end

end