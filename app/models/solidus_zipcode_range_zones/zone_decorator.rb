module SolidusZipcodeRangeZones
  module ZoneDecorator
    def self.prepended(base)
      base.has_many :zipcode_ranges

      base.accepts_nested_attributes_for :zipcode_ranges

      base.scope :with_member_ids, ->(state_ids, country_ids, zipcode) do
        if !state_ids.present? && !country_ids.present? && !zipcode.present?
          none
        else
          spree_zone_members_table = Spree::ZoneMember.arel_table
          matching_state =
            spree_zone_members_table[:zoneable_type].eq("Spree::State").
            and(spree_zone_members_table[:zoneable_id].in(state_ids))
          matching_country =
            spree_zone_members_table[:zoneable_type].eq("Spree::Country").
            and(spree_zone_members_table[:zoneable_id].in(country_ids))

          zipcode_ranges_table = Spree::ZipcodeRange.arel_table

          zipcode = zipcode.gsub(/[^\d]/, '')[0..-4]

          matching_country_or_state = matching_state.or(matching_country)
          matching_zipcode_range = zipcode_ranges_table[:start].lteq(zipcode).and(zipcode_ranges_table[:end].gteq(zipcode))

          left_joins(:zipcode_ranges)
            .left_joins(:zone_members)
            .where(matching_country_or_state.or(matching_zipcode_range)).distinct
        end
      end

      base.scope :for_address, ->(address) do
        if address
          with_member_ids(address.state_id, address.country_id, address.zipcode)
        else
          none
        end
      end
    end

    def kind
      return 'zip' if zipcodes.present?

      super
    end

    Spree::Zone.prepend self
  end
end
