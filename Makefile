export LAB_NAME=dotnet-api-fargate
export PROJECT_NAME=SampleAPI
export REPO_NAME=sample_api
export ACCOUNT_NUMBER=$$(aws sts get-caller-identity --outpu  text --query 'Account')
export AWS_DEFAULT_REGION=ap-southeast-1
export ECR_URL=${ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
export ALB_URL=$$(terraform output -json | jq -r '.url.value')

# You should setup your credential inside the lab env
lab:
	docker build -t ${LAB_NAME} .

login-lab:
	docker run \
		-it \
		--rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${PWD}:/aws \
		-p 5000:5000 \
		-p 80:80 \
		--entrypoint sh \
		--name ${LAB_NAME} \
		${LAB_NAME}

sample-project:
	dotnet new webapi -o src/${PROJECT_NAME} --no-https

# Override run url as docker within docker has localhost lookback issue to start as http://localhost:5000
run-project:
	dotnet run -p src/${PROJECT_NAME} --urls=http://*:5000/

repo:
	aws ecr create-repository --repository-name ${REPO_NAME}

login:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

image:
	docker build --rm --pull -f src/${PROJECT_NAME}/Dockerfile -t ${REPO_NAME} .
	docker tag ${REPO_NAME}:latest ${ECR_URL}/${REPO_NAME}:latest
	docker push ${ECR_URL}/${REPO_NAME}:latest

init:
	terraform init infra

plan:
	terraform plan infra

apply:
	terraform apply -auto-approve infra

test:
	curl http://${ALB_URL}/WeatherForecast

kill:
	terraform destroy -auto-approve infra
	aws ecr list-images --repository-name ${REPO_NAME} --query 'imageIds[*].imageDigest' --output text | while read imageId; do aws ecr batch-delete-image --repository-name ${REPO_NAME} --image-ids imageDigest=$$imageId; done
	aws ecr delete-repository --repository-name ${REPO_NAME}