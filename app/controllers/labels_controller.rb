class LabelsController < ApplicationController
  @@labels = nil

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

  def load_labels(only_errors = "false")
    if only_errors == "false"
      source = "data/labels.json"
      labels = File.file?(source) ? JSON.parse(File.read(source), object_class: OpenStruct) : []
    else
      labels = @@labels
    end

    fedex = Fedex::Shipment.new(:key            => 'O21wEWKhdDn2SYyb',
                                :password       => 'db0SYxXWWh0bgRSN7Ikg9Vunz',
                                :account_number => '510087780',
                                :meter          => '119009727',
                                :mode           => 'test')

    # Apply changes on data labels
    labels.each do |label|
      if only_errors == "false"
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

        # Mass units and values
        label.parcel["mass_unit"].downcase!

        # Converts values if not "kg"
        if label.parcel["mass_unit"] != "kg"
          label.parcel["weight"] *= get_factor(label.parcel["mass_unit"])
          label.parcel["mass_unit"] = "kg"
        end

        # Calculate total weight
        label.parcel["total_weight"] = label.parcel["weight"] > label.parcel["volumetric_weight"] ? label.parcel["weight"]
                                                                                                  : label.parcel["volumetric_weight"]
      end

      if only_errors == "false" || (only_errors == "true" && label.parcel["fedex"]["error"] != "")
        # ----------
        # Get Fedex info
        label.parcel["fedex"] = {}
        label.parcel["overweight"] = nil
        label.parcel["overweight_rounded"] = nil

        begin
          result = fedex.track(:tracking_number => label["tracking_number"])

        rescue StandardError => e
          puts e.message + " (on getting record for 'tracking number' = #{label["tracking_number"]})"

          label.parcel["fedex"]["error"] = e.message

        else
          begin
            track = result.first

          rescue StandardError => e
            puts e.message + " (on getting record info for 'tracking number' = #{label["tracking_number"]})"

            label.parcel["fedex"]["error"] = e.message

          else
            label.parcel["fedex"]["weight"] = track.details[:package_weight][:value].to_f
            label.parcel["fedex"]["units"] = track.details[:package_weight][:units].downcase

            # Converts values if not "kg"
            if label.parcel["fedex"]["units"] != "kg"
              label.parcel["fedex"]["weight"] *= get_factor(label.parcel["fedex"]["units"])
              label.parcel["fedex"]["units"] = "kg"
            end

            label.parcel["fedex"]["weight"] = label.parcel["fedex"]["weight"].ceil(4)
            label.parcel["fedex"]["error"] = ""

            label.parcel["overweight"] = (label.parcel["fedex"]["weight"] - label.parcel["total_weight"]).ceil(4)
            label.parcel["overweight_rounded"] = label.parcel["overweight"].ceil
          end
        end

        puts label.parcel["fedex"]
      end
    end

    return labels
  end

  def index
    reload = params.key?(:reload) ? params[:reload] : "true"

    if reload == "true"
      only_errors = params.key?(:only_errors) ? params[:only_errors] : "false"
      @@labels = load_labels(only_errors)
    end

    @labels = @@labels
  end
end
