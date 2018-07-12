module SolidusZipcodeRangeZones
  module ZoneDecorator
    def self.prepended(base)
      base.has_many :zipcode_ranges, through: :zone_members, source: :zoneable, source_type: 'Spree::ZipcodeRange'

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
          matching_zipcode_range =
            spree_zone_members_table[:zoneable_type].eq("Spree::ZipcodeRange")
            .and(zipcode_ranges_table[:start].lteq(zipcode).and(zipcode_ranges_table[:end].gteq(zipcode)))

          joins(:zone_members)
            .joins("LEFT JOIN spree_zipcode_ranges on spree_zipcode_ranges.id = spree_zone_members.zoneable_id AND spree_zone_members.zoneable_type = 'Spree::ZipcodeRange'")
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
      return 'zip' if zipcode_ranges.exists?

      super
    end

    Spree::Zone.prepend self
  end
end
