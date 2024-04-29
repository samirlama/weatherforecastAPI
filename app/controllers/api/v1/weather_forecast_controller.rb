require 'net/http'

module Api
  module V1
    class WeatherForecastController < ApplicationController
      BASE_URL = 'https://api.weather.gov'.freeze
      def hourly_forecast
        lat = params[:lat]
        lon = params[:lon]

        if lat.blank? || lon.blank?
          render json: { error: 'Latitude (lat) and Longitude (lon) parameters are required' }, status: :bad_request
          return
        end

        point_response = fetch_data("/points/#{lat},#{lon}")
        if point_response['error']
          render json: { error: 'Failed to retrieve weather data' }, status: :bad_request
          return
        end

        grid_id = point_response['properties']['gridId']
        grid_x = point_response['properties']['gridX']
        grid_y = point_response['properties']['gridY']

        forecast_response = fetch_data("/gridpoints/#{grid_id}/#{grid_x},#{grid_y}/forecast/hourly")
        if forecast_response['error']
          render json: { error: 'Failed to retrieve hourly forecast' }, status: :bad_request
          return
        end

        render json: forecast_response['properties']['periods']
      end

      private
      def fetch_data(path)
        url = URI("#{BASE_URL}#{path}")

        response = Net::HTTP.get_response(url)

        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.error("Failed to fetch data from #{url}: #{response.code} - #{response.message}")
          return { 'error' => 'API request failed' }
        end

        JSON.parse(response.body)
      rescue StandardError => e
        Rails.logger.error("Error fetching data from #{url}: #{e.message}")
        { 'error' => 'API request failed' }
      end
    end
  end
end

