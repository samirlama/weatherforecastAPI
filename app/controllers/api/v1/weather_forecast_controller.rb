module Api
  module V1
    class WeatherForecastController < ApplicationController
      def hourly_forecast
        render json: { data: "sadad" }
      end
    end
  end
end

