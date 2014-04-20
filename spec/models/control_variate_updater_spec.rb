require 'spec_helper'

describe ControlVariateUpdater do
  describe '.update' do
    let!(:instance) { create(:simulator_instance) }
    let!(:control_variable) do
      ControlVariable.create(simulator_instance_id: instance.id,
                             name: 'var', expectation: 0.5, id: 2)
    end
    let!(:player_control_variable) do
      PlayerControlVariable.create(
        simulator_instance_id: instance.id, name: 'pvar',
        role: 'R1', expectation: 10.0, id: 5)
    end
    let(:cv_params) do
      { '2' => { 'expectation' => '1.0', 'role_coefficients' => {
        '1' => { 'coefficient' => 6.2 }, '2' => { 'coefficient' => '-2.3' } } }
      }
    end
    let(:pcv_params) do
      { '5' => {
        'expectation' => '10.0', 'coefficient' => '-3.2', 'role' => 'R1' } }
    end
    before do
      control_variable.role_coefficients.create(role: 'R1', id: 1)
      control_variable.role_coefficients.create(role: 'R2', id: 2)
    end
    it 'locks down and updates the appropriate control variables' do
      ControlVariateUpdater.update(cv_params, pcv_params)
      expect(ControlVariable.first.role_coefficients.find(1).coefficient)
        .to eq(6.2)
      expect(ControlVariable.first.role_coefficients.find(2).coefficient)
        .to eq(-2.3)
      expect(ControlVariable.first.expectation).to eq(1.0)
      expect(PlayerControlVariable.first.coefficient).to eq(-3.2)
      expect(PlayerControlVariable.first.expectation).to eq(10.0)
    end
  end
end
