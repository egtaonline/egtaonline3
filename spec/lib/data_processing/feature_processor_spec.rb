require 'data_processing'

describe FeatureProcessor do
  describe ".parse" do
    let(:features){ { "first" => 1, "second" => 0.5, "third" => "-23" } }
    let(:extended_features){ { "nest" => { "nested" => 21 }, "non-numeric" => true, "non-numeric_string" => "Hello" } }

    context "when feature map is empty" do
      it "returns empty maps" do
        FeatureProcessor.parse({}).should == { "features" => {}, "extended_features" => {} }
        FeatureProcessor.parse(nil).should == { "features" => {}, "extended_features" => {} }
      end
    end

    context "when only control-variate style features are present" do
      it "leaves extended features empty" do
        FeatureProcessor.parse(features).should == { "features" => features, "extended_features" => {} }
      end
    end

    context "when only non-control-variate style features are present" do
      it "leaves features empty" do
        FeatureProcessor.parse(extended_features).should == { "features" => {}, "extended_features" => extended_features }
      end
    end

    context "when a mixture of features are present" do
      it "separates them appropriately" do
        FeatureProcessor.parse(features.merge(extended_features)).should == { "features" => features, "extended_features" => extended_features }
      end
    end
  end
end