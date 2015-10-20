require "surveygizmo/client/version"
require "oauth"

module Surveygizmo
  class Client
    API_URL = "http://restapi.surveygizmo.com/v4"

    def initialize(omniauth_data)
      access_token_data = omniauth_data['access_token']
      consumer_data = access_token_data['consumer']
      @consumer = create_consumer(consumer_data)
      @access_token = create_access_token(
        @consumer,
        access_token_data['token'],
        access_token_data['secret']
      )
    end

    def accountuser(filters = [], page = 1, page_size = 20)
      get_paginated_resource("accountuser", filters, page, page_size)
    end

    def contactlist(page = 1, page_size = 50, filters = [])
      get_paginated_resource("contactlist", page, page_size, filters)
    end

    def contactlist_contact(page = 1, page_size = 50, filters = [], list_id)
      get_paginated_resource("contactlist/#{list_id}", page, page_size)
    end

    def survey(filters = [], page = 1, page_size = 50)
      get_paginated_resource("survey", filters, page, page_size)
    end

    def surveycampaign(page = 1,filters = [], page_size = 50, survey_id)
      get_paginated_resource(
        "survey/#{survey_id}/surveycampaign",
        filters,
        page,
        page_size
      )
    end

    def surveycampaign_contact(
      page = 1,
      filters = [],
      page_size = 50,
      survey_id,
      campaign_id
    )

      get_paginated_resource(
        "survey/#{survey_id}/surveycampaign/#{campaign_id}/contact",
        page,
        page_size
      )
    end

    def add_contact_to_list(list_id, contact_params)
      parsed_response(
        post_request(
          "/contactlist/#{list_id}?_method=POST#{contact_params}"
        )
      )
    end

    def add_contact_to_campaign(survey_id, campaign_id, contact_params)
      parsed_response(
        put_request(
          "/survey/#{survey_id}/surveycampaign/"\
          "#{campaign_id}/contact/?_method=PUT&#{contact_params}"
        )
      )
    end

    def update_campaign_contact(
      survey_id,
      campaign_id,
      contact_id,
      contact_params
    )
      parsed_response(
        post_request(
          "survey/#{survey_id}/surveycampaign/"\
          "#{campaign_id}/contact/#{contact_id}?_method=POST"\
          "&#{contact_params}"
        )
      )
    end

    private

    def get_paginated_resource(resource, filters = [], page = 1, page_size = 50)
      filter = compose_filter(filters)
      parsed_response(get_request(
          "/#{resource}.json?page=#{page}&resultsperpage=#{page_size}#{filter}"
        )
      )
    end

    def parsed_response(response)
      JSON.parse(response.body)
    end

    def get_request(endpoint, headers = {})
      @access_token.get(endpoint, headers)
    end

    def put_request(endpoint, headers = {})
      @access_token.put(endpoint, headers)
    end

    def post_request(endpoint, headers = {})
      @access_token.get(endpoint, headers)
    end

    def compose_filter(filters)
      usable_filters = filters.select do |f|
        f.size == 3
      end
      usable_filters.each_with_object("").with_index do |(f, memo), index|
        memo << "&filter[field][#{index}]=#{f['field']}"\
                "&filter[operator][#{index}]=#{f['operator']}"\
                "&filter[value][#{index}]=#{f['value']}"
      end
    end

    def create_consumer(consumer_data)
      OAuth::Consumer.new(
        consumer_data['key'],
        consumer_data['secret'],
        { :site => API_URL}
      )
    end

    def create_access_token(consumer, access_token, access_token_secret)
      OAuth::AccessToken.new(consumer, access_token, access_token_secret)
    end

  end
end
