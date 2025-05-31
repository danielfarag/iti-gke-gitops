T.PHONY: infra dinfra images helm dhelm k8s dk8s connection start clean

BACKEND_IMAGE := $(shell yq '.image.repository' "./cd/backend/values.yaml")
BACKEND_TAG := $(shell yq '.image.tag' "./cd/backend/values.yaml")

FRONTEND_IMAGE := $(shell yq '.image.repository' "./cd/frontend/values.yaml")
FRONTEND_TAG := $(shell yq '.image.tag' "./cd/frontend/values.yaml")

REGISTRY_HOST := $(shell echo $(BACKEND_IMAGE) | cut -d'/' -f1)

infra:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra apply -auto-approve
dinfra:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra destroy -auto-approve

images:
	@gcloud auth configure-docker $(REGISTRY_HOST)

	@docker build -t $(BACKEND_IMAGE):latest -t $(BACKEND_IMAGE):$(BACKEND_TAG) ./backend

	@docker push $(BACKEND_IMAGE):latest
	@docker push $(BACKEND_IMAGE):$(BACKEND_TAG)

	@docker build -t $(FRONTEND_IMAGE):latest -t $(FRONTEND_IMAGE):$(FRONTEND_TAG) ./frontend

	@docker push $(FRONTEND_IMAGE):latest
	@docker push $(FRONTEND_IMAGE):$(FRONTEND_TAG)

helm:
	@terraform -chdir=terraform/helm init
	@terraform -chdir=terraform/helm apply -auto-approve
dhelm:
	@terraform -chdir=terraform/helm init
	@terraform -chdir=terraform/helm destroy -auto-approve
k8s:
	@terraform -chdir=terraform/k8s init
	@terraform -chdir=terraform/k8s apply -var-file="./vars.tfvars" -auto-approve

dk8s:
	@terraform -chdir=terraform/k8s init
	@terraform -chdir=terraform/k8s destroy -var-file="./vars.tfvars" -auto-approve

connection:
	@sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
	@gcloud auth configure-docker $(REGISTRY_HOST)
	@gcloud container clusters get-credentials iti-cluster --zone us-central1 --project iti-gcp-course



refresh_token: 
	@terraform -chdir=terraform/infra init


start: infra images helm k8s connection

clean: refresh_token dk8s dhelm dinfra