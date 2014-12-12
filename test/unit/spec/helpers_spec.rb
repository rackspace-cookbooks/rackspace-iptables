require_relative 'spec_helper'

describe 'RackspaceIptables::Helpers' do
  context 'convert_nodes_to_rules' do
    rules_to_add = '-s 10.0.0.1 -j ACCEPT'
    weight = 99
    comment = 'no comment'

    # dummy 'node' variable for helpers
    mock_current_node = {}
    mock_current_node['name'] = 'dummy node'
    RackspaceIptables::Helpers.mock_current_node(mock_current_node)

    it 'should return empty when given empty' do
      results = RackspaceIptables::Helpers.convert_nodes_to_rules([], rules_to_add, weight, comment)
      expect(results.empty?).to be_truthy
    end

    it 'should return empty when given bad node data' do
      other_node = {}
      other_node['name'] = 'other'

      nodes = [other_node]
      results = RackspaceIptables::Helpers.convert_nodes_to_rules(nodes, rules_to_add, weight, comment)
      expect(results.empty?).to be_truthy
    end
  end
end
