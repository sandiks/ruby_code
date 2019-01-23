# Sinatra geo-api app

This is a very small example app showing how to accept and return JSON as an
API.


https://github.com/netronixgroup/backend-ruby/blob/master/TestTask.md

Task.create(name: 'deliver 3', pickup_location:  [-73.93,44.10])
Task.create(name: 'deliver 3', pickup_location:  [-73.93,45.10])
Task.create(name: 'deliver 3', pickup_location:  [-73.93,46.10])
Task.create(name: 'deliver 3', pickup_location:  [-73.93,42.10])
Task.create(name: 'deliver 3', pickup_location:  [-73.93,41.10])
Task.create(name: 'deliver 3', pickup_location: {lat: 41.10, lng: -73.93}, status: 'new' )

##show tasks

curl -i -X GET -H "ACCESS_TOKEN: driver11" -H "Content-Type: application/json" -d '{"location":"-73.93,42.10", "radius": "230"}' http://localhost:4567/api/v1/tasks

##show one task
curl -i -X GET -H "Content-Type: application/json" http://localhost:4567/api/v1/tasks/58591bbed392b91e29a40aa8

##create 
curl -i -X POST -H "Content-Type: application/json" -d '{"name":"deliver1", "pickup_location":"-73.93,42.10","delivery_location":"-73.93,42.10"}' http://localhost:4567/api/v1/tasks

##change status
curl -i -X PATCH -H "Content-Type: application/json" -d '{"status":"assigned"}' http://localhost:4567/api/v1/update_status/585864a3d392b969430b03dd
