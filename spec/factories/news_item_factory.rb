FactoryBot.define do
  factory :news_item do
    transient do
      collection_count { 1 }
    end

    sequence(:id) { |n| n }
    sequence(:slug) { |n| "slug-#{n}" }
    start_date { Time.zone.yesterday }
    sequence(:title) { |n| "News item #{n}" }
    display_style { NewsItem::DISPLAY_STYLE_REGULAR }
    show_on_xi { true }
    show_on_uk { true }
    show_on_updates_page { false }
    show_on_home_page { false }
    show_on_banner { false }

    collections do
      attributes_for_list :news_collection, collection_count
    end

    content do
      <<~CONTENT
        This is some **body** content

        1. With
        2. A list
        3. In it
      CONTENT
    end

    trait :uk_only do
      show_on_xi { false }
    end

    trait :xi_only do
      show_on_uk { false }
    end

    trait :home_page do
      show_on_home_page { true }
    end

    trait :banner do
      show_on_banner { true }
    end

    trait :updates_page do
      show_on_updates_page { true }
    end

    trait :with_precis do
      precis { "first paragraph\n\nsecond paragraph" }
    end
  end
end
