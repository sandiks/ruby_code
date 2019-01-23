# server.rb
require 'sinatra'
require "sinatra/namespace"
require 'mongoid'

# DB Setup
Mongoid.load! "mongoid.config"

# Models
class Task
  include Mongoid::Document

  field :name, type: String
  field :status, type: String
  field :pickup_location, type: Array
  field :delivery_location, type: Array
  validates :name, presence: true

  index({ name: 'text' })
  index( { pickup_location: '2d' }, { min: -180, max: 180 })
end

# Serializers
class TaskSerializer

  def initialize(task)
    @task = task
  end

  def as_json(*)
    data = {
      id: @task.id.to_s,
      name: @task.name,
      pickup_location: @task.pickup_location,
      delivery_location: @task.delivery_location,
      status: @task.status,
    }
    data[:errors] = @task.errors if @task.errors.any?
    data
  end

end

# Endpoints
get '/' do
  'Welcome!'
end

namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message: 'Invalid JSON' }.to_json
      end
    end

    def task
      @task ||= Task.where(id: params[:id]).first
    end

    def halt_if_not_found!
      halt(404, { message: 'Task Not Found'}.to_json) unless task
    end

    def serialize(task)
      TaskSerializer.new(task).to_json
    end

    def authenticate_as_driver!
      success = request.env["HTTP_ACCESS_TOKEN"] == 'driver11'
      halt(404, { message: 'you are not driver'}.to_json) unless success
    end

    def authenticate_as_manager!
      success = request.env["HTTP_ACCESS_TOKEN"] == 'manager11'
      halt(404, { message: 'you are not manager'}.to_json) unless success
    end
  end

  get '/tasks' do
    authenticate_as_driver!

    data = json_params
    radius=data["radius"].to_i
    loc = data["location"].split(',').map { |el| el.to_f  }
    tasks = Task.where(:pickup_location => {"$near" => loc , '$maxDistance' => radius.fdiv(111.12)})
    tasks.map { |task| TaskSerializer.new(task) }.to_json
  end

  get '/tasks/:id' do |id|
    halt_if_not_found!
    serialize(task)
  end

  post '/tasks' do
    authenticate_as_manager!

    data = json_params
    data["pickup_location"] = data["pickup_location"].split(',').map { |el| el.to_f  }
    data["delivery_location"] = data["delivery_location"].split(',').map { |el| el.to_f  }
    data["status"] = "new"
    task = Task.new(data)
    halt 422, serialize(task) unless task.save
    response.headers['Location'] = "#{base_url}/api/v1/tasks/#{task.id}"
    status 201
  end

  patch '/update_status/:id' do |id|
    authenticate_as_driver!

    halt_if_not_found!
    data = json_params
    halt 422, serialize(task) unless task.update_attributes({status: data['status']})
    serialize(task)
  end

end
