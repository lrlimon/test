class LabelsController < ApplicationController
  def get_labels(source = nil)
    source = "data/labels.json" if source == nil

    return File.file?(source) ? JSON.parse(File.read(source), object_class: OpenStruct) : []
  end

  def index
    @labels = get_labels
  end
end
