cf add-network-policy front-end-container back-end-container --protocol tcp --port 8080


# IGNORE BELOW.  MOVED COMMANDS BELOW INTO YAML/MANIFESTS FILE
###########################################
# For front-end-container
cd front-end-container
cf push front-end-container -b python_buildpack -m 256M --random-route

# For back-end-container
cd ../back-end-container
cf push back-end-container -b python_buildpack -m 256M --no-route

#Set up container-to-container networking

# Allow front-end-container to connect to back-end-container on port 5000
cf add-network-policy front-end-container back-end-container --protocol tcp --port 8080

# Create and map route for back-end container.  Creates a DNS entry in CF liek:  back-end-container.apps.internal
cf map-route back-end-container apps.internal --hostname back-end-container

# Update front end app to point to that DNS by setting environmental variable.
cf set-env front-end-container BACKEND_URL http://back-end-container.apps.internal:8080
cf restage front-end-container
