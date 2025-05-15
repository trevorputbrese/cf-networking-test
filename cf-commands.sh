cf add-network-policy front-end-container back-end-container --protocol tcp --port 8080


# IGNORE EVERYTHING BELOW THIS LINE AS WELL.  MOVED ALL COMMANDS BELOW INTO YAML FILE
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

# Update front end app to poitn to that DNS by setting environmental variable.
cf set-env front-end-container BACKEND_URL http://back-end-container.apps.internal:8080
cf restage front-end-container



# IGNORE EVERYTHING BELOW THIS LINE AS WELL
###########################################

# For front-end-container
cd front-end-container
cf push front-end-container -b python_buildpack -m 256M --random-route

# For back-end-container
cd ../back-end-container
cf push back-end-container -b python_buildpack -m 256M --no-route

#setting up container-to-container networking

# Allow front-end-container to connect to back-end-container on port 5000
cf add-network-policy front-end-container back-end-container --protocol tcp --port 5000

TROUBLESHOOTING:
On first CF push I got the following error:
    "Failed to resolve 'back-end-container' ([Errno -2] Name or service not known)"

indicates that your front-end app is trying to connect to the back-end app using the app name (back-end-container) as a hostname, but Cloud Foundry container-to-container networking does not automatically provide DNS-based resolution based solely on app names.

FIX:
Cloud Foundry provides internal container-to-container networking via IP addresses and ports, but it does not automatically create DNS records matching your app names.

Instead, your front-end app needs to use the special environment variables provided by Cloud Foundry: CF_INSTANCE_INTERNAL_IP and CF_INSTANCE_PORT.

There are two main approaches:

Step-by-step fix:

Map an internal route to your backend app (this is key!):
cf map-route back-end-container apps.internal --hostname back-end-container

This creates an internal DNS entry like:  back-end-container.apps.internal

Then update front-end app to point to that internal route by setting an environmental variable:
cf set-env front-end-container BACKEND_URL http://back-end-container.apps.internal:5000
cf restage front-end-container

