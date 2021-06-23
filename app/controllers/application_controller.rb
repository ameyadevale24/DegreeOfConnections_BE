class ApplicationController < ActionController::API
    def status
        render json: { data: 'OK' }
    end
end
