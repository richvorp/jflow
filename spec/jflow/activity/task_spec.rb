require 'spec_helper'

describe JFlow::Activity::Task do

  class FooActivity
  end

  let(:mock_activity) do
    double(:activity,{
      :input => "--- foo\n",
      :task_token => "tokenbar",
      :activity_type => activity_type
    })
  end

  let(:activity_type) do
    double(:activity_type, {name: 'somename.somemethod', version: '1.0'})
  end

  let(:task) { JFlow::Activity::Task.new(mock_activity) }

  describe "#input" do
    it "should parse the input properly" do
      expect(task.input).to eq "foo"
    end
  end

  describe "#token" do
    it "should return token" do
      expect(task.token).to eq "tokenbar"
    end
  end

  describe "#name" do
    it "should return name" do
      expect(task.name).to eq "somename.somemethod"
    end
  end

  describe "#version" do
    it "should return version" do
      expect(task.version).to eq "1.0"
    end
  end

  describe "#klass" do
    it "should return the proper class if registered" do
      expect(JFlow.configuration.activity_map).to receive(:klass_for)
                                              .and_return("Foo")
      expect(task.klass).to eq "Foo"
    end

    it "should return raise if not found" do
      expect(JFlow.configuration.activity_map).to receive(:klass_for)
                                              .and_return(nil)
      expect{task.klass}.to raise_error RuntimeError, "Could not find code to run for given activity"
    end
  end

  describe "#method" do
    context "with specified method" do
      it "should return method if set" do
        expect(task.method).to eq "somemethod"
      end
    end
    context "with default" do
      let(:activity_type) do
        double(:activity_type, {name: 'somename', version: '1.0'})
      end
      it "should return the default method" do
        expect(task.method).to eq "process"
      end
    end
  end

  describe "#run!" do
    before(:each) do
      expect(JFlow.configuration.activity_map).to receive(:klass_for)
                                              .and_return(FooActivity)
    end
    it "should call the proper method on the expected class" do
      expect_any_instance_of(FooActivity).to receive(:somemethod)
      expect(task).to receive(:completed!)
      task.run!
    end
    it "should call completed with the right ouput" do
      expect_any_instance_of(FooActivity).to receive(:somemethod).and_return("result")
      expect(task).to receive(:completed!).with("result")
      task.run!
    end
    it "should call completed with the default string if none returned" do
      expect_any_instance_of(FooActivity).to receive(:somemethod)
      expect(task).to receive(:completed!).with("done")
      task.run!
    end
  end

  describe "#completed!" do
    it "should send the right signal to SWF" do
      expect(JFlow.configuration.swf_client).to receive(:respond_activity_task_completed)
                                            .with(:task_token => task.token, :result => "foo")
      task.completed!("foo")
    end
  end

  describe "#failed!" do
    let(:exception){double(:exception,{ :message => "foo", :backtrace => ["b","a","r"]})}
    it "should send the right signal to SWF" do
      expect(JFlow.configuration.swf_client).to receive(:respond_activity_task_failed)
                                            .with({
                                              :task_token => task.token,
                                              :reason => "foo",
                                              :details => "b\na\nr"
                                            })
      task.failed!(exception)
    end
  end

end