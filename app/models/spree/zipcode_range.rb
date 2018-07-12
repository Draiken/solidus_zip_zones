module Spree
  class ZipcodeRange < ApplicationRecord
    has_one :zone_member, class_name: 'Spree::ZoneMember', as: :zoneable
    has_one :zone, class_name: 'Spree::Zone', through: :zone_member
  end
end
