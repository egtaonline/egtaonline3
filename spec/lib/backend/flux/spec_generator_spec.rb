require 'backend/flux/spec_generator'

describe SpecGenerator do
  describe '#generate' do
    let(:symmetry_group1) { double(role: 'B', count: 2, strategy: 'Shade1') }
    let(:symmetry_group2) { double(role: 'B', count: 1, strategy: 'Shade2') }
    let(:symmetry_group3) { double(role: 'S', count: 3, strategy: 'FPrice') }
    let(:symmetry_group4) { double(role: 'S', count: 1, strategy: 'SPrice') }
    let(:local_data_path) { 'fake/path' }
    let(:profile) do
      double(symmetry_groups: [symmetry_group1, symmetry_group2,
                               symmetry_group3, symmetry_group4],
             simulator_instance: double(configuration: { fake: 'value' }))
    end
    let(:simulation) { double(profile: profile, id: 23) }
    let(:spec_generator) { SpecGenerator.new(local_data_path) }

    it 'creates a simulation_spec.json file' do
      f = double('File')
      File.should_receive(:open).with(
        "#{local_data_path}/#{simulation.id}/simulation_spec.json", 'w'
        ).and_yield(f)
      f.should_receive(:write).with(MultiJson.dump(
        'assignment' => {
          'B' => %w(Shade1 Shade1 Shade2),
          'S' => %w(FPrice FPrice FPrice SPrice) },
        'configuration' => { fake: 'value' }))
      spec_generator.generate(simulation)
    end
  end
end
