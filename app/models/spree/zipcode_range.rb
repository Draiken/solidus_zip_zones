module Spree
  class ZipcodeRange < ApplicationRecord
    belongs_to :zone, class_name: 'Spree::Zone'
  end
end
