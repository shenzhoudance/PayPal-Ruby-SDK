require 'paypal-sdk-core/http'

module PayPal::SDK::Core
  
  # API class provide default functionality for accessing the API web services.
  # == Example
  #   api      = API.new("AdaptivePayments")
  #   response = api.request("GetPaymentOptions", "")
  class API
    
    include PayPal::SDK::Core::Configuration
    include PayPal::SDK::Core::Logging
    
    HTTP_HEADER = {}
    
    attr_accessor :http, :uri
    
    # Initlaize API object
    # === Argument
    # * <tt>service_path</tt> -- (Optional) Service end point or prefix path 
    # * <tt>environment</tt>  -- (Optional) Configuration environment to load
    # * <tt>options</tt> -- (Optional) Override configuration.
    # === Example
    #  new("AdaptivePayments")
    #  new("https://svcs.sandbox.paypal.com/AdaptivePayments")
    #  new("AdaptivePayments")
    #  new("AdaptivePayments", :development)
    #  new(:wsdl_service)       # It load wsdl_service configuration 
    def initialize(service_path = "/", environment = nil, options = {})
      unless service_path.is_a? String
        environment, options, service_path = service_path, environment || {}, "/"
      end   
      set_config(environment, options)
      create_http_connection(service_path)
    end
    
    # Create HTTP connection based on given service path or configured end point
    # === Argument
    # * <tt>service_path<tt> - Service path or Service End point
    def create_http_connection(service_path)
      service_path = "#{service_endpoint}/#{service_path}" unless service_path =~ /^https?:\/\//
      @uri  = URI.parse(service_path)
      @http = HTTP.new(@uri.host, @uri.port)
      @http.set_config(config)
      @uri.path = @uri.path.gsub(/\/+/, "/")      
    end
    
    # Get service end point
    def service_endpoint
      config.end_point 
    end
    
    # Get default HTTP header
    def http_header
      HTTP_HEADER
    end
    
    # Generate HTTP request for given action and parameters
    # === Arguments
    # * <tt>action</tt> -- Action to perform
    # * <tt>params</tt> -- (Optional) Parameters for the action
    # * <tt>initheader</tt> -- (Optional) HTTP header
    def request(action, params = {}, initheader = {})
      path, content = format_request(action, params)
      response      = @http.post(path, content, http_header.merge(initheader))
      format_response(action, response)
    end

    # Format Request data
    # == Arguments
    # * <tt>action</tt> -- Request action
    # * <tt>params</tt> -- Request parameters
    # == Return
    # * <tt>path</tt> -- Formated request path
    # * <tt>params</tt> -- Formated request Parameters
    def format_request(action, params)
      [ @uri.path, params ]
    end
    
    # Format Response object
    # == Argument
    # * <tt>action</tt> -- Request action
    # * <tt>response</tt> -- HTTP response object
    def format_response(action, response)
      response
    end    
  end
end