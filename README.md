# security-take-home-assignment

## initial steps to setup the project the project
- Got to iam and create a service account with required permissions 
- Then generate a key on the service account that you created and pass it to the providers file
- open commons.tfvars and add the correct project id and name
- now login to google account and set the project in the terminal using gcloud (gcloud auth login and gcloud config set project PROJECT_ID)
- Intial phase setup is done and ready to deploy using the below commands

## How to run 
```
make kubernetes.init
make kubernetes.plan
make kubernetes.apply
make database.init
make database.plan
make database.apply
```
