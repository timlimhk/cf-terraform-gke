# Source: https://gist.github.com/f7e56816710e839038109fe7c4abc01b

#################################################################################################################################
# Applying GitOps And Continuous Delivery (CD) On Infrastructure Using Terraform, Codefresh, And Google Kubernetes Engine (GKE) #
#################################################################################################################################

####################
# Getting The Code #
####################

echo open https://github.com/vfarcic/cf-terraform-gke

# Replace `[...]` with the GitHub organization
export GH_ORG=timlimhk

git clone https://github.com/$GH_ORG/cf-terraform-gke

cd cf-terraform-gke

cp orig/*.tf .

cp orig/codefresh.yml .

#####################################
# Setting Up A Google Cloud Project #
#####################################

gcloud auth login

#export PROJECT_ID=doc-$(date +%Y%m%d%H%M%S)
export PROJECT_ID=doc-cf-gke

gcloud projects create $PROJECT_ID

gcloud iam service-accounts \
    create devops-catalog \
    --project $PROJECT_ID \
    --display-name devops-catalog

gcloud iam service-accounts \
    keys create account.json \
    --iam-account devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --project $PROJECT_ID

gcloud projects \
    add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/owner

open https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID

###################################
# Preparing Terraform Definitions #
###################################

#export BUCKET_NAME=doc-$(date +%Y%m%d%H%M%S)
export BUCKET_NAME=doc-cf-gke

export REGION=us-east1

gsutil mb \
    -p $PROJECT_ID \
    -l $REGION \
    -c "NEARLINE" \
    gs://$BUCKET_NAME

cat variables.tf

gcloud container get-server-config \
    --project $PROJECT_ID \
    --region $REGION

# Replace `[...]` with any of the `validMasterVersions`
export VERSION="1.17.13-gke.2600"

cat variables.tf \
    | sed -e "s@CHANGE_PROJECT_ID@$PROJECT_ID@g" \
    | sed -e "s@CHANGE_VERSION@$VERSION@g" \
    | tee variables.tf

cat main.tf

cat main.tf \
    | sed -e "s@CHANGE_BUCKET@$BUCKET_NAME@g" \
    | tee main.tf

cat output.tf

git add .

git commit -m "Initial commit"

git push

###########################################
# Defining A Continuous Delivery Pipeline #
###########################################

cat codefresh.yml

###############################################
# Creating And Configuring Codefresh Pipeline #
###############################################

open https://codefresh.io/

cat account.json

#######################################
# Applying Infrastructure Definitions #
#######################################

terraform init

terraform refresh

export KUBECONFIG=$PWD/kubeconfig

gcloud container clusters \
    get-credentials \
    $(terraform output cluster_name) \
    --project \
    $(terraform output project_id) \
    --region \
    $(terraform output region)

kubectl get nodes

##############################################################
# Incorporating Pull Requests Into Infrastructure Management #
##############################################################

git checkout -b destroy

# Change the variable `destroy` to `true` in `variables.tf`

git add .

git commit -m "Destroying everything"

git push \
    --set-upstream origin destroy

open https://github.com/$GH_ORG/cf-terraform-gke

git checkout master

