RSpec.describe Physics::Wattage do
  let(:wattage) {
    Physics::Wattage.new(
      riders_weight: 80.0,
      riders_height: 1.80,
      bike: Physics::Bikes::RoadbikeTops
    )
  }
  describe "Physics Tests von Kreuzotter" do
    specify 'Unit test' do
      wattage.update_environment(
        slope_percent: 0,
        height_over_zero: 350,
        temperature: 20,
        headwind: 0,
        cadence: 90
      )
      expect(wattage.A_total).to be_within(0.001).of(0.5187)
      expect(wattage.Cr).to be == 0.00330
      expect(wattage.Ka).to be_within(0.001).of(0.29902388990919004)
      expect(wattage.CrDyn).to be == 0.1
      expect(wattage.Frg).to be_within(0.02).of(2.8973835)
      expect(wattage.speed_for_wattage(160)).to be_within(0.2).of(27.3)
      expect(wattage.wattage_for_speed(27.3)).to be_within(5).of(160)
    end

    specify 'Anstieg' do
      wattage.update_environment(
        slope_percent: 10,
        height_over_zero: 350,
        temperature: 20,
        headwind: 0,
        cadence: 90
      )
      expect(wattage.instance_variable_get("@slope")).to be == 0.09966865249116204
      expect(wattage.CrDyn).to be == 0.09950371902099892
      expect(wattage.Frg).to be_within(1).of(90.24677211864274)
      expect(wattage.speed_for_wattage(160)).to be_within(0.2).of(6.2)
    end

    specify 'Abfall' do
      wattage.update_environment(
        slope_percent: -8,
        height_over_zero: 350,
        temperature: 20,
        headwind: 0,
        cadence: 90
      )
      # expect(wattage.instance_variable_get("@slope")).to be == 0.09966865249116204
      # expect(wattage.CrDyn).to be == 0.09950371902099892
      # expect(wattage.Frg).to be_within(1).of(90.24677211864274)
      expect(wattage.speed_for_wattage(160)).to be_within(0.2).of(57.2)
    end

    specify 'Gegenwind' do
      wattage.update_environment(
        slope_percent: 0,
        height_over_zero: 350,
        temperature: 20,
        headwind: 15,
        cadence: 90
      )
      expect(wattage.speed_for_wattage(160)).to be_within(0.2).of(18.8)
    end
    specify 'Rueckenwind' do
      wattage.update_environment(
        slope_percent: 0,
        height_over_zero: 350,
        temperature: 20,
        headwind: -15,
        cadence: 90
      )
      expect(wattage.speed_for_wattage(160)).to be_within(0.2).of(37.1)
    end
  end

  specify 'Beschleunigung' do
    wattage.update_environment(
      slope_percent: 0,
      height_over_zero: 350,
      temperature: 20,
      headwind: 0,
      cadence: 90
    )

    v = wattage.simulate_acceleration(start_speed: 0, duration: 5, wattage: 160)
    expect(v).to be > 0

    1000.times do
      v = wattage.simulate_acceleration(start_speed: v, duration: 5, wattage: 160)
    end
    expect(wattage.speed_for_wattage(160)).to be_within(0.5).of(v)
  end

  specify 'Schrägwinde'
end
