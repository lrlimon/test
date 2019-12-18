require "rails_helper"

labels = LabelsController.new
data_labels = labels.get_labels
fedex_api = labels.get_fedex_api

RSpec.describe LabelsController, type: :controller do
  describe "Label JSON data" do
    context "input file" do
      it "file exists" do
        expect(File.file?("data/labels.json")).to eq(true)
      end

      it "file contains data" do
        expect(data_labels.length).to_not eq(0)
      end
    end
  end

  describe "Fedex" do
    context "API" do
      it "connection available" do
        expect(fedex_api).to_not be_nil
      end

      it "access data" do
        expect(fedex_api.track(:tracking_number => data_labels[0]["tracking_number"])).to_not be_nil
      end
    end
  end
end
