class LabelsController < ApplicationController
  def get_factor(um = nil)
    case um
    when "in"
      return 2.54

    when "lb"
      return 0.454

    # Exception
    else
      return 1
    end
  end

  def get_labels(source = nil)
    source = "data/labels.json" if source == nil
    labels = File.file?(source) ? JSON.parse(File.read(source), object_class: OpenStruct) : []

    # Apply changes on data labels
    labels.each do |label|
      # Distance units and values
      label.parcel["distance_unit"].downcase!

      # Converts values if not "cm"
      if label.parcel["distance_unit"] != "cm"
        factor = get_factor(label.parcel["distance_unit"])

        label.parcel["length"] *= factor
        label.parcel["width"] *= factor
        label.parcel["height"] *= factor
        label.parcel["distance_unit"] = "cm"
      end

      # Gets volumetric weight
      label.parcel["volumetric_weight"] = label.parcel["length"] * label.parcel["width"] * label.parcel["height"] / 5000.0
      label.parcel["volumetric_weight_rounded"] = label.parcel["volumetric_weight"].ceil.to_f

      # Mass units and values
      label.parcel["mass_unit"].downcase!

      # Converts values if not "kg"
      if label.parcel["mass_unit"] != "kg"
        label.parcel["weight"] *= get_factor(label.parcel["mass_unit"])
        label.parcel["mass_unit"] = "kg"
      end

      label.parcel["weight_rounded"] = label.parcel["weight"].ceil.to_f

      # Calculate total weight
      label.parcel["total_weight"] = label.parcel["weight_rounded"] > label.parcel["volumetric_weight_rounded"] ? label.parcel["weight_rounded"]
                                                                                                                : label.parcel["volumetric_weight_rounded"]
    end

    return labels
  end

  def index
    @labels = get_labels
  end
end
