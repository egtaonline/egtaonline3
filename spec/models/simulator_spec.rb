require 'spec_helper'

describe Simulator do
  describe 'setup/validation:' do
    before :all do
      Simulator.set_callback(:validation, :before,
                             :setup_simulator, if: :source_changed?)
    end

    after :all do
      Simulator.skip_callback(:validation, :before, :setup_simulator)
    end

    context 'with valid simulator' do
      before do
        Backend.should_receive(:prepare_simulator)
      end

      context 'new simulator' do
        it 'sets up the simulator, locally and on the backend' do
          simulator = Simulator.create!(
            name: 'fake_sim', version: '1.0',
            email: 'test@example.com',
            source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
          expect(simulator.configuration)
            .to eq('parm-integer' => 60, 'parm-float' => 0.0,
                   'parm-string' => 'CDA')
        end
      end

      context 'existing simulator' do
        it 'replaces the existing simulator, locally and on the backend' do
          simulator = Simulator.create!(
            name: 'fake_sim', version: '1.0',
            email: 'test@example.com',
            source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
          simulator.configuration['parm-integer'] = 61
          simulator.save!
          Backend.should_receive(:prepare_simulator)
          FileUtils.should_receive(:rm_rf).with(
            File.join(Rails.root, 'simulator_uploads', simulator.fullname))
          simulator.update_attributes(
            source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
          expect(simulator.configuration)
            .to eq('parm-integer' => 60, 'parm-float' => 0.0,
                   'parm-string' => 'CDA')
        end
      end
    end

    context 'invalid simulator' do
      it 'informs of missing defaults.json and missing script/batch file' do
        simulator = Simulator.new(
          name: 'broken', version: '1.0',
          email: 'test@example.com',
          source: File.new("#{Rails.root}/spec/support/data/broken.zip"))
        expect(simulator).to have(2).errors_on(:source)
        expect(simulator.errors[:source]).to include(
          "did not have defaults.json in folder #{simulator.name}")
        expect(simulator.errors[:source]).to include(
          'did not find script/batch within ' +
          File.join(Rails.root, 'simulator_uploads', simulator.fullname) +
          "/#{simulator.name}")
      end
    end
  end

  let(:simulator) { create(:simulator) }

  describe '#add_role' do
    it 'adds a new empty role' do
      simulator.add_role('All')
      expect(simulator.reload.role_configuration).to eq('All' => [])
    end

    it 'adds a role coefficient if a control variable exists' do
      simulator_instance = create(:simulator_instance, simulator: simulator)
      cv = create(:control_variable, simulator_instance: simulator_instance)
      simulator.add_role('All')
      role_coef = RoleCoefficient.last
      expect(role_coef.role).to eq('All')
      expect(role_coef.control_variable_id).to eq(cv.id)
    end
  end

  describe '#remove_role' do
    before do
      simulator.role_configuration = { 'All' => ['A1'] }
      simulator.save!
      simulator.reload
    end

    context 'when the role is present' do
      it 'removes the role' do
        simulator.remove_role('All')
        expect(simulator.reload.role_configuration).to eq({})
      end
    end

    context 'when the role is not present' do
      it 'does nothing to the role configuration' do
        simulator.reload.remove_role('B')
        expect(simulator.reload.role_configuration).to eq('All' => ['A1'])
      end
    end
  end

  describe '#add_strategy' do
    it 'adds the strategy to specified role' do
      simulator.add_strategy('All', 'A1')
      simulator.add_strategy('All', 'A2')
      expect(simulator.reload.role_configuration).to eq('All' => %w(A1 A2))
    end
  end

  describe '#remove_strategy' do
    it 'removes the specified strategy from the specified role if possible' do
      simulator.role_configuration = { 'Role1' => %w(A B), 'Role2' => ['A'] }
      simulator.remove_strategy('Role1', 'A')
      expect(simulator.reload.role_configuration)
        .to eq('Role1' => ['B'], 'Role2' => ['A'])
      simulator.remove_strategy('Role2', 'B')
      expect(simulator.reload.role_configuration)
        .to eq('Role1' => ['B'], 'Role2' => ['A'])
    end
  end
end
