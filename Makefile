all:
	#rm -f terraform.tfstate
	#rm -f terraform.tfstate.backup
	#rm -f .terraform.lock.hcl
	#rmdir .terraform
	terraform init
	rm -f random_data_generator.zip 
	rm -f example.zip
	cd lambda_scripts && zip random_data_generator.zip random_data_generator.py
	cd lambda_scripts && zip example.zip example.js
	cd ..
	terraform destroy -auto-approve
	terraform init
	terraform plan -var-file terraform.tfvars
	terraform apply -auto-approve
