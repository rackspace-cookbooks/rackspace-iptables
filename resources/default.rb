actions :add, :search
default_action :add

attribute :chain, kind_of: String, default: 'INPUT'
attribute :rule, kind_of: String, default: nil
attribute :weight, kind_of: Integer, default: 50
attribute :comment, kind_of: String, default: nil

def initialize(*args)
  super
  @action = :add
  @supports = { report: true, notify: true }
end

state_attrs :chain,
            :rule,
            :weight,
            :comment
