export YC_TOKEN=$(yc iam create-token)
export TF_VAR_yc_cloud_id=$(yc config get cloud-id)
export TF_VAR_yc_folder_id=$(yc config get folder-id)
terraform plan -var zone=ru-central1-a -var network_name=otus -var cidr_k8s=10.0.0.0/24 -var yc_folder_id="$YC_FOLDER_ID"
terraform apply -auto-approve -var zone=ru-central1-a -var network_name=otus -var cidr_k8s=10.0.0.0/24 -var yc_folder_id="$YC_FOLDER_ID"
