require 'spec_helper'

describe AttributeCartographer do
  after(:each) do
    TestClass.instance_variable_set :@mapper, nil
  end

  let(:klass) {
    class TestClass
      include AttributeCartographer
    end
  }

  describe "#initialize" do


    it "doesn't require an argument" do
      lambda { klass.new }.should_not raise_error
    end
  end

  describe "#original_attributes" do
    it "is the attributes given on initialize" do
      klass.new(a: :b).original_attributes.should == { a: :b }
    end
  end

  describe "#mapped_attributes" do
    subject { klass.new(attributes).mapped_attributes }

    context "with no mapping" do
      let(:attributes) { { "Attribute" => "Value" } }

      it { should be_empty }
    end

    context "with a mapping" do
      before { klass.map "Attribute", "attribute" }

      context "and no attributes to map" do
        let(:attributes) { {} }

        it { should be_empty }
      end

      context "and attributes to map" do
        let(:attributes) { { "Attribute" => "Value" } }

        it { should == { "attribute" => "Value" } }
      end
    end
  end

  describe ".map" do
    context "with a single argument" do
      context "and no lambda" do
        before { klass.map "Attribute" }

        it "creates an entry in mapped_attributes matching the key name" do
          klass.new("Attribute" => "Value").mapped_attributes["Attribute"].should == "Value"
        end

        it "creates an entry in unmapped_attributes matching the key name" do
          klass.new("Attribute" => "Value").unmapped_attributes["Attribute"].should == "Value"
        end
      end

      context "and a 1-arity lambda" do
        before { klass.map "Attribute", ->(v) { v.downcase } }

        it "creates an entry in mapped_attributes matching the key name, mapping the value with the lambda" do
          klass.new("Attribute" => "Value").mapped_attributes["Attribute"].should == "value"
        end
      end

      context "and a 2-arity lambda" do
        before { klass.map "Attribute", ->(k,v) { [k.downcase, v.downcase] } }

        it "creates an entry in mapped_attributes using the lambda for the key and value" do
          klass.new("Attribute" => "Value").mapped_attributes["attribute"].should == "value"
        end

        it "doesn't raise an error when the attributes hash is missing a mapped key" do
          lambda { klass.new("OtherAttribute" => "OtherValue") }.should_not raise_error
        end
      end
    end

    context "with two arguments" do
      context "and no lambda" do
        before { klass.map "Attribute", "attribute" }

        context "with attributes matching the left key, passing the value through" do
          it "maps the left key to the right key" do
            klass.new("Attribute" => "Value").mapped_attributes["attribute"].should == "Value"
          end
        end

        context "with attributes matching the right key, passing the value through" do
          it "maps the right key to the left key" do
            klass.new("attribute" => "Value").unmapped_attributes["Attribute"].should == "Value"
          end
        end
      end

      context "and a single lambda" do
        before { klass.map "Attribute", "attribute", ->(v) { v.downcase } }

        context "with attributes matching the left key" do
          it "maps the left key to the right key using the lambda to alter the value" do
            klass.new("Attribute" => "Value").mapped_attributes["attribute"].should == "value"
          end
        end

        context "with attributes matching the right key" do
          it "doesn't map the right key as it's a one-way mapping" do
            klass.new("attribute" => "value").mapped_attributes["Attribute"].should be_nil
          end
        end
      end

      context "and two lambdas" do
        before { klass.map "Attribute", "attribute", ->(v) { v.downcase }, ->(v) { v.upcase } }

        context "with attributes matching the left key" do
          it "maps the left key to the right key, using the first lambda to map the value" do
            klass.new("Attribute" => "Value").mapped_attributes["attribute"].should == "value"
          end
        end

        context "with attributes matching the right key, passing the value through" do
          it "maps the right key to the left key, using the second lambda to map the value" do
            klass.new("attribute" => "value").unmapped_attributes["Attribute"].should == "VALUE"
          end
        end
      end

      context "and a >1-arity lambda" do
        it "raises an error" do
          lambda { klass.map :a, :b, ->(k,v) { v + 1 } }.should raise_error(AttributeCartographer::InvalidArgumentError)
        end
      end

      context "and two lambda where the attributes have identical keys" do
        before { klass.map "attribute", "attribute", ->(v) { v.downcase }, ->(v) { v.upcase } }

        context "with attributes matching the left key" do
          it "maps the left key to the right key, using the first lambda to map the value" do
            klass.new("attribute" => "Value").mapped_attributes["attribute"].should == "value"
          end

          it "maps the right key to the left key, using the second lambda to map the value" do
            klass.new("attribute" => "Value").unmapped_attributes["attribute"].should == "VALUE"
          end
        end
      end

      context "and two lambda where the attributes have identical keys but map different types" do
        before { klass.map "attribute", "attribute", ->(v) { v.split('') }, ->(v) { v.join('') } }

        context "with attributes matching the left key" do
          it "maps the left key to the right key, using the first lambda to map the value" do
            klass.new("attribute" => "Va").mapped_attributes["attribute"].should == ['V', 'a']
          end

          it "maps the right key to the left key, using the second lambda to map the value" do
            klass.new("attribute" => ["V", "a"]).unmapped_attributes["attribute"].should == "Va"
          end
        end
      end
    end

    context "with an array" do
      let(:attributes) { { "Attribute1" => "Value1", "Attribute2" => "Value2" } }
      subject { klass.new(attributes).mapped_attributes }

      context "and no lambda" do
        before { klass.map %w{ Attribute1 Attribute2 } }

        it { should == attributes }
      end

      context "and a 1-arity lambda" do
        before { klass.map %w{ Attribute1 Attribute2 }, ->(v) { v.downcase } }

        it { should == { "Attribute1" => "value1", "Attribute2" => "value2" } }
      end

      context "and a 2-arity lambda" do
        before { klass.map %w{ Attribute1 Attribute2 }, ->(k,v) { [k.downcase, v.downcase] } }

        it { should == { "attribute1" => "value1", "attribute2" => "value2" } }
      end
    end
  end
end
