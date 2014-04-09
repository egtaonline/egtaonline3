require 'spec_helper'

describe ControlVariableBuilder do
  let(:simulator_instance){ double(id: 1) }
  let(:cv_builder){ ControlVariableBuilder.new(simulator_instance) }
  let(:validated_data) do
    {
      'features' => { 'featureA' => 34.0 },
      'extended_features' => {
        'featureB' => [37, 38],
        'featureC' => {
          'C1' => 40.0, 'C2' => 42.0
        }
      },
      'symmetry_groups' => [
        {
          'role' => 'Role1',
          'strategy' => 'Strategy1',
          'players' => [
            {
              'payoff' => 2992.73,
    			    'features' => {
    				    'featureA' => 0.001
    				  },
    				  'extended_features' => {
    				    'featureB' => [2.0, 2.1]
    			    }
    			  }
          ]
        },
        {
          'role' => 'Role2',
          'strategy' => 'Strategy2',
          'players' => [
            {
              'payoff' => 2929.34,
              'features' => {
    				    'featureA' => 0.001,
    				    'featureB' => 23
    				  }
            },
            {
    				  'payoff' => 2000.00,
    				  'features' => { 'featureA' => 0.96 }
    			  }
          ]
        }
      ]
    }
  end

  # For now, making many requests to database.  Check if there are performance issues
  describe '#extract_control_variables' do
    it 'creates a new control variable for each unique entry' do
      ControlVariable.should_receive(:find_or_create_by).with(name: 'featureA', simulator_instance_id: simulator_instance.id)
      PlayerControlVariable.should_receive(:find_or_create_by).with(name: 'featureA', simulator_instance_id: simulator_instance.id, role: 'Role1')
      PlayerControlVariable.should_receive(:find_or_create_by).with(name: 'featureA', simulator_instance_id: simulator_instance.id, role: 'Role2')
      PlayerControlVariable.should_receive(:find_or_create_by).with(name: 'featureB', simulator_instance_id: simulator_instance.id, role: 'Role2')
      cv_builder.extract_control_variables(validated_data)
    end
  end
end
