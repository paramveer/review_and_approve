require 'spec_helper'

class AR < SuperModel::Base
  extend ReviewAndApprove::ModelAdditions
  review_and_approve :field => :hello, :by => [:one, :two]
  attr_accessor :one, :two
end

class Ability
  include CanCan::Ability
end

describe ReviewAndApprove::ModelAdditions do
  describe "#review_and_approve" do
    it "sets up an attr_accessor for the given field" do 
      a = AR.new
      lambda{a.hello="world"}.should_not raise_exception
      a.hello.should=="world"
    end

    it "should set up published_version method" do
      a = AR.new
      a.class.method_defined?(:published_version).should be_true
    end

    describe "#published_version" do
      it "reads method values from cache" do
        a = AR.new
        a.stubs(:id).returns 1

        object = mock('object')
        object.expects(:read).with("ReviewAndApprove_AR_1_as_json").returns 1
        object.expects(:read).with("ReviewAndApprove_AR_1_to_json").returns 2
        Rails.stubs(:cache).returns object
        
        a.published_version(:as_json).should==1
        a.published_version(:to_json).should==2
      end
    end

    describe "after_save behavior for able users" do
      context "if object.publish field is true" do
        it "writes all setup methods to cache" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = true
          abl = Ability.new
          abl.can(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl
          

          object = mock 'object'
          object.expects(:write).with("ReviewAndApprove_AR_1_one", nil).returns 1
          object.expects(:write).with("ReviewAndApprove_AR_1_two", nil).returns 2
          object.expects(:write).with("ReviewAndApprove_AR_1_three", nil).never
          Rails.stubs(:cache).returns object

          a.save
        end
      end
      context "if object.publish field is false" do
        it "does not write anything to cache" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = false
          abl = Ability.new
          abl.can(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl
          

          object = mock 'object'
          object.expects(:write).with("ReviewAndApprove_AR_1_one", nil).never
          object.expects(:write).with("ReviewAndApprove_AR_1_two", nil).never

          Rails.stubs(:cache).returns object
          a.save
        end
      end
    end
    describe "for users that are not allowed to publish record" do
      context "if publish field set to true before save" do
        it "forces save to return false" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = true
          abl = Ability.new
          abl.cannot(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl

          object = mock 'object'
          object.expects(:write).with("ReviewAndApprove_AR_1_one", nil).raises
          object.expects(:write).with("ReviewAndApprove_AR_1_two", nil).raises
          Rails.stubs(:cache).returns object

          a.valid?.should be_false
          lambda{ a.save }.should_not raise_exception

        end
      end
    end
  end
end