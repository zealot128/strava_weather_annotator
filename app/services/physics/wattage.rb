# rubocop:disable Naming/MethodName,Naming/VariableName,Metrics/ParameterLists
module Physics
  class Wattage
    # Trittfrequenz Windabh.
    CCAD = 0.002

    def initialize(
      # kg
      riders_weight: 80.0,
      # m
      riders_height: 1.80,
      bike:,
      front_wheel: bike.front_wheel,
      back_wheel: bike.back_wheel,
      bike_weight: bike.mass
    )
      @riders_weight = riders_weight
      @riders_height = riders_height
      @front_wheel = front_wheel
      @back_wheel = back_wheel
      @bike = bike
      @bike_weight = bike_weight
    end

    def simulate_acceleration(start_speed: 0, duration: 5, wattage: )
      a = fTotal / mass
      vms = a * duration + (1/3.6r) * start_speed
      vms * 3.6
    end

    def update_environment(
      slope_percent: 0, # percent
      height_over_zero: 250, # m over normal zero
      temperature: 20, # celsius
      pressure: nil, # hpa
      headwind: 0, # km/h
      cadence: 90 # 1/min
    )
      @slope = Math.atan(slope_percent * 0.01)
      @height_over_zero = height_over_zero
      @temperature = temperature
      @headwind = headwind / 3.6r
      @cadence = cadence
      @pressure = nil
    end

    def speed_for_wattage(wattage)
      cardB =
        Rational(3.0 * self.Frg - 4 * @headwind * self.CrDyn, 9 * self.Ka) -
        Rational(self.CrDyn**2, 9 * (self.Ka**2)) -
        (@headwind * @headwind) / 9
      cardA = -(((self.CrDyn**3) - (@headwind**3)) / 27.0 +
                @headwind * (
                  5 * @headwind * self.CrDyn +
                  Rational(4 * (self.CrDyn**2), self.Ka) -
                  6 * self.Frg
                ) / (18 * self.Ka) -
                Rational(wattage, (2 * self.Ka * @bike.Cm)) -
                Rational(self.CrDyn * self.Frg, 6 * (self.Ka**2)))
      sqrt = (cardA**2) + (cardB**3)
      vms = if sqrt >= 0
              ire = cardA - Math.sqrt(sqrt)
              (cardA + Math.sqrt(sqrt))**(1 / 3r) +
                (ire < 0 ? -((-ire)**(1 / 3r)) : (ire**(1 / 3r)))
            else
              2 * Math.sqrt(-cardB) * Math.cos(Math.acos(cardA / Math.sqrt((-cardB**3))) / 3)
            end
      vms -= Rational(2 * @headwind, 3) + Rational(self.CrDyn, 3.0 * self.Ka)
      vms * 3.6
    end

    def wattage_for_speed(speed)
      vw = (1 / 3.6r) + @headwind
      y = @bike.Cm * speed * (self.Ka * (vw * (vw < 0 ? -vw : vw)) + self.Frg + speed * self.CrDyn)

      y *= 0.5 if @bike.tandem?
      y
    end

    def CwA
      self.CwaBike + self.CwaRider
    end
    alias A_total CwA

    # Rollwiderstandsbeiwert
    def CrEff
      @bike.LoadV * @bike.CCrV * @front_wheel.Cr + (1.0 - @bike.LoadV) * @back_wheel.Cr
    end
    alias Cr CrEff

    def CwaBike
      @bike.CdBike * (
        @front_wheel.A * @bike.CATireV +
        @back_wheel.A * @bike.CATireH +
        @bike.AFrame
      )
    end

    def CwaRider
      (1 + @cadence * CCAD) *
        @bike.Cd * adipos *
        (((@riders_height - adipos) * @bike.Sin) + adipos)
    end

    def adipos
      @bike.adipos(riders_weight: @riders_weight, riders_height: @riders_height)
    end

    # luftdichte
    def luftdichte
      Rational(1013, rs + @temperature + 273.15).to_f
    end

    # TODO: Luftfeuchtigkeit/Regen
    # luftdichte
    def Ka
      if @pressure
        rs = 287.058
        Rational(@pressure * 100, rs * (@temperature + 273.15)) * Rational(self.CwA, 2)
      else
        176.5 * Math.exp(-@height_over_zero * 0.0001253) * Rational(self.CwA, (273.15 + @temperature))
      end
    end

    # Rollwiderstandskraft (auf schiefer Ebene normalisiert) plus ggf. Hangabtriebskraft
    def Frg
      9.80665 * (@bike_weight + @riders_weight) * (self.CrEff * Math.cos(@slope) + Math.sin(@slope))
    end

    # Koeffizient für den geschwindigkeitsabhängigen dynamischen Rollwiderstand, hier approximiert mit 0.1
    def CrDyn
      0.1 * Math.cos(@slope)
    end
  end
end
