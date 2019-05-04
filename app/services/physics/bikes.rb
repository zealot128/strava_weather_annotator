module Physics
  module Bikes
    class Wheel
      class_attribute :Cr
      class_attribute :A
    end

    class RaceWheel < Wheel
      self.Cr = 0.0033
      self.A = 0.021
    end

    class MediumHighPressureWheel < Wheel
      self.Cr = 0.0031
      self.A = 0.031
    end

    class WideHighPressureWheel < Wheel
      self.Cr = 0.0029
      self.A = 0.042
    end

    class TourWheel < Wheel
      self.Cr = 0.0050
      self.A = 0.048
    end

    class RinkowskiWheel < Wheel
      self.Cr = 0.0016
      self.A = 0.042
    end

    class KnobbyWheel < Wheel
      self.Cr = 0.0046
      self.A = 0.055
    end

    class BaseBike
      class_attribute :name
      # Luftwiderstandsbeiwert
      class_attribute :Cd

      class_attribute :Sin

      class_attribute :CdBike

      # Stirnfläche Rahmen
      class_attribute :AFrame

      class_attribute :front_wheel
      class_attribute :back_wheel

      class_attribute :CATireV
      class_attribute :CATireH

      # weight distribution, more front, or more back wheel pressure
      class_attribute :LoadV

      class_attribute :CCrV

      class_attribute :Cm

      class_attribute :mass

      def self.adipos(riders_weight:, riders_height:)
        Math.sqrt(Rational(riders_weight, riders_height * 750))
      end

      def self.tandem?
        false
      end
    end

    class Hollandrad < BaseBike
      self.name = 'Hollandrad'
      self.Cd =  0.95
      self.Sin = 0.95
      self.CdBike = 2.0
      self.AFrame = 0.06
      self.CATireV = 1.1
      self.CATireH = 0.9
      self.LoadV = 0.33
      self.CCrV = 1.0
      self.Cm = 1.03
      self.mass = 18
      self.front_wheel = TourWheel
      self.back_wheel = TourWheel
    end

    class BaseRoadbike < BaseBike
      self.CdBike = 1.5
      self.AFrame = 0.06
      self.CATireV = 1.1
      self.CATireH = 0.9
      self.CCrV = 1.0
      self.Cm = 1.025
      self.mass = 9.0
      self.AFrame = 0.048
      self.front_wheel = RaceWheel
      self.back_wheel = RaceWheel
    end

    class RoadbikeTops < BaseRoadbike
      self.name = 'Rennrad Oberlenker-Haltung'
      self.Cd = 0.82
      self.Sin = 0.89
      self.CdBike = 1.5
      self.LoadV = 0.4
    end

    class RoadbikeDrops < BaseRoadbike
      self.name = 'Rennrad Unterlenker-Haltung'
      self.Cd = 0.6
      self.Sin = 0.67
      self.LoadV = 0.45
    end

    #             race,  HP med, HP wide, tour,  rink,  knobby
    WHEEL_CR = [0.0033, 0.0031, 0.0029, 0.0050, 0.0016, 0.0046].freeze
    WHEEL_A = [0.021, 0.031, 0.042,  0.048, 0.042, 0.055]
    DEFINITIONS = [
      {
        name: 'MTB',
        asBike: "mtb",
        afCd: 0.79,
        afSin: 0.85,
        afCdBike: 1.5,
        AFrame: 0.06,
        afAFrame: 0.052,
        afCATireV: 1.1,
        afCATireH: 0.9,
        afLoadV: 0.45,
        afCCrV: 1.0,
        afCm: 1.025,
        afMBikeDef: 12,
        aiTireFDef: 5,
        aiTireRDef: 5
      },
      {
        name: 'Tandem (Rennlenker)',
        asBike: "tandem",
        afCd: 0.35,
        afSin: 0.7,
        afCdBike: 1.7,
        AFrame: 0.07,
        afAFrame: 0.06,
        afCATireV: 1.1,
        afCATireH: 0.9,
        afLoadV: 0.5,
        afCCrV: 1.0,
        afCm: 1.05,
        afMBikeDef: 17.8,
        aiTireFDef: 1,
        aiTireRDef: 1
      },
      {
        name: 'Rennrad Obenlenker-Haltung',
        asBike: "racetops",
        afCd: 0.82,
        afSin: 0.89,
        afCdBike: 1.5,
        AFrame: 0.055,
        afAFrame: 0.048,
        afCATireV: 1.1,
        afCATireH: 0.9,
        afLoadV: 0.4,
        afCCrV: 1.0,
        afCm: 1.025,
        afMBikeDef: 9.5,
        aiTireFDef: 0,
        aiTireRDef: 0
      },
      {
        name: 'Rennrad Unterlenker-Haltung',
        asBike: "racedrops",
        afCd: 0.6,
        afSin: 0.67,
        afCdBike: 1.5,
        AFrame: 0.055,
        afAFrame: 0.048,
        afCATireV: 1.1,
        afCATireH: 0.9,
        afLoadV: 0.45,
        afCCrV: 1.0,
        afCm: 1.025,
        afMBikeDef: 9.5,
        aiTireFDef: 0,
        aiTireRDef: 0
      },
      { asBike: "tria",
        name: 'Triathlon-Rennrad',
        afCd: 0.53,
        afSin: 0.64,
        afCdBike: 1.25,
        AFrame: 0.055,
        afAFrame: 0.048,
        afCATireV: 1.1,
        afCATireH: 0.7,
        afLoadV: 0.47,
        afCCrV: 1.0,
        afCm: 1.025,
        afMBikeDef: 9.5,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "superman",
        name: 'Rennrad Superman-Position',
        afCd: 0.47,
        afSin: 0.55,
        afCdBike: 0.9,
        AFrame: 0.05,
        afAFrame: 0.044,
        afCATireV: 0.9,
        afCATireH: 0.7,
        afLoadV: 0.48,
        afCCrV: 1.0,
        afCm: 1.025,
        afMBikeDef: 8,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "lwbuss",
        name: 'Langliegerad Untenlenker (Alltags-Ausstattung)',
        afCd: 0.85,
        afSin: 0.64,
        afCdBike: 1.7,
        AFrame: 0.045,
        afAFrame: 0.039,
        afCATireV: 0.66,
        afCATireH: 0.9,
        afLoadV: 0.32,
        afCCrV: 1.25,
        afCm: 1.04,
        afMBikeDef: 18,
        aiTireFDef: 1,
        aiTireRDef: 3 },
      { asBike: "swbuss",
        name: 'Kurzliegerad Untenlenker (Alltagsausstattung)',
        afCd: 0.67,
        afSin: 0.51,
        afCdBike: 1.6,
        AFrame: 0.042,
        afAFrame: 0.036,
        afCATireV: 0.8,
        afCATireH: 0.8,
        afLoadV: 0.55,
        afCCrV: 1.25,
        afCm: 1.04,
        afMBikeDef: 15.5,
        aiTireFDef: 2,
        aiTireRDef: 3 },
      { asBike: "swbass",
        name: 'Kurzliegerad Obenlenker (Rennausstattung)',
        afCd: 0.6,
        afSin: 0.44,
        afCdBike: 1.25,
        AFrame: 0.036,
        afAFrame: 0.031,
        afCATireV: 0.85,
        afCATireH: 0.84,
        afLoadV: 0.55,
        afCCrV: 1.25,
        afCm: 1.04,
        afMBikeDef: 11.5,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "ko4",
        name: 'Tiefliegerad Obenlenker',
        afCd: 0.5,
        afSin: 0.37,
        afCdBike: 1.2,
        AFrame: 0.027,
        afAFrame: 0.023,
        afCATireV: 0.77,
        afCATireH: 0.49,
        afLoadV: 0.63,
        afCCrV: 1.25,
        afCm: 1.05,
        afMBikeDef: 11.8,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "ko4tailbox",
        name: 'Tiefliegerad mit Heckflosse',
        afCd: 0.41,
        afSin: 0.37,
        afCdBike: 1.15,
        AFrame: 0.03,
        afAFrame: 0.026,
        afCATireV: 0.77,
        afCATireH: 0.3,
        afLoadV: 0.63,
        afCCrV: 1.25,
        afCm: 1.05,
        afMBikeDef: 13.5,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "whitehawk",
        name: 'Tiefliegerad mit Vollverschalung (White Hawk)',
        afCd: 0,
        afSin: 0,
        afCdBike: 0.036,
        AFrame: 1,
        afAFrame: 1,
        afCATireV: 0.1,
        afCATireH: 0.13,
        afLoadV: 0.55,
        afCCrV: 1.25,
        afCm: 1.06,
        afMBikeDef: 18,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "questclosed",
        name: 'Velomobil Quest',
        afCd: 0,
        afSin: 0,
        afCdBike: 0.09,
        AFrame: 1,
        afAFrame: 1,
        afCATireV: 0.26,
        afCATireH: 0.16,
        afLoadV: 0.72,
        afCCrV: 1.5,
        afCm: 1.09,
        afMBikeDef: 32,
        aiTireFDef: 0,
        aiTireRDef: 0 },
      { asBike: "handtrike",
        name: 'Handbike 3 Räder',
        afCd: 0.62,
        afSin: 0.55,
        afCdBike: 1.5,
        AFrame: 0.05,
        afAFrame: 0.046,
        afCATireV: 0.9,
        afCATireH: 2,
        afLoadV: 0.5,
        afCCrV: 1.5,
        afCm: 1.03,
        afMBikeDef: 18,
        aiTireFDef: 0,
        aiTireRDef: 0 }
    ].freeze
  end
end
